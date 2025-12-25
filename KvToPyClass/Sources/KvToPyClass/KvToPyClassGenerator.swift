import Foundation
import KvParser
import PySwiftAST
import PySwiftCodeGen

/// Generates Python class code from KV language rules
///
/// Kivy's Builder dynamically applies KV rules to widgets at runtime.
/// This generator instead creates equivalent Python class definitions that
/// produce the same widget tree structure and property bindings.
public struct KvToPyClassGenerator {
    
    private let module: KvModule
    
    public init(module: KvModule) {
        self.module = module
    }
    
    /// Generate Python code for all dynamic classes and rules
    public func generate() throws -> String {
        var statements: [Statement] = []
        
        // Collect all widget types that need to be imported
        let widgetTypes = collectWidgetTypes()
        
        // Add imports
        statements.append(contentsOf: generateImports(for: widgetTypes))
        
        // Generate class definitions for rules and templates
        for rule in module.rules {
            statements.append(contentsOf: try generateClassForRule(rule))
        }
        
        // Convert to Python source code
        let pyModule = Module.module(statements)
        let code = try formatModule(pyModule)
        
        // Add blank lines between imports and classes, and between classes
        return addBlankLines(to: code)
    }
    
    private func addBlankLines(to code: String) -> String {
        var lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var result: [String] = []
        var lastWasImport = false
        
        for (index, line) in lines.enumerated() {
            let isImport = line.hasPrefix("from ") || line.hasPrefix("import ")
            let isClass = line.hasPrefix("class ")
            
            // Add blank line after last import before first class
            if lastWasImport && isClass {
                result.append("")
            }
            
            // Add blank line between classes
            if isClass && index > 0 && !lines[index - 1].isEmpty && !lines[index - 1].hasPrefix("from ") && !lines[index - 1].hasPrefix("import ") {
                result.append("")
            }
            
            result.append(line)
            lastWasImport = isImport
        }
        
        return result.joined(separator: "\n")
    }
    
    // MARK: - Helpers
    
    private func formatModule(_ module: Module) throws -> String {
        // Use PySwiftCodeGen to convert AST to Python source code
        return PySwiftCodeGen.generatePythonCode(from: module)
    }
    
    private func makeName(_ id: String) -> Name {
        Name(id: id, ctx: .load, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)
    }
    
    private func makeConstant(_ value: ConstantValue) -> Constant {
        Constant(value: value, kind: nil, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)
    }
    
    // MARK: - Import Generation
    
    /// Collect all widget types used in the module
    private func collectWidgetTypes() -> Swift.Set<String> {
        var types = Swift.Set<String>()
        
        for rule in module.rules {
            switch rule.selector {
            case .dynamicClass(_, let bases):
                types.formUnion(bases)
            case .name(let name):
                types.insert(name)
            default:
                break
            }
            // Collect from children
            collectTypesFromChildren(rule.children, into: &types)
        }
        
        return types
    }
    
    private func collectTypesFromChildren(_ children: [KvWidget], into types: inout Swift.Set<String>) {
        for child in children {
            types.insert(child.name)
            collectTypesFromChildren(child.children, into: &types)
        }
    }
    
    /// Convert widget type name to appropriate kivy.uix module path
    private func kivyModuleForWidget(_ widgetName: String) -> String {
        let lowercased = widgetName.lowercased()
        return "kivy.uix.\(lowercased)"
    }
    
    private func generateImports(for widgetTypes: Swift.Set<String>) -> [Statement] {
        var imports: [Statement] = []
        var lineNum = 1
        
        // Import each widget type from its kivy.uix module
        for widgetType in widgetTypes.sorted() {
            let modulePath = kivyModuleForWidget(widgetType)
            let importStmt = ImportFrom(
                module: modulePath,
                names: [Alias(name: widgetType, asName: nil)],
                level: 0,
                lineno: lineNum,
                colOffset: 0,
                endLineno: nil,
                endColOffset: nil
            )
            imports.append(.importFrom(importStmt))
            lineNum += 1
        }
        
        // Import App if any bindings use 'app'
        let needsApp = module.rules.contains { rule in
            rule.properties.contains { property in
                property.value.contains("app.")
            }
        }
        
        if needsApp {
            let appImport = ImportFrom(
                module: "kivy.app",
                names: [Alias(name: "App", asName: nil)],
                level: 0,
                lineno: lineNum,
                colOffset: 0,
                endLineno: nil,
                endColOffset: nil
            )
            imports.append(.importFrom(appImport))
            lineNum += 1
        }
        
        // Collect property types that need to be imported
        let propertyTypes = collectPropertyTypes()
        
        if !propertyTypes.isEmpty {
            // Import specific property types from kivy.properties
            let propsImport = ImportFrom(
                module: "kivy.properties",
                names: propertyTypes.sorted().map { Alias(name: $0, asName: nil) },
                level: 0,
                lineno: lineNum,
                colOffset: 0,
                endLineno: nil,
                endColOffset: nil
            )
            imports.append(.importFrom(propsImport))
        }
        
        return imports
    }
    
    private func collectPropertyTypes() -> Swift.Set<String> {
        var types = Swift.Set<String>()
        
        for rule in module.rules {
            let baseClasses: [String]
            switch rule.selector {
            case .dynamicClass(_, let bases):
                baseClasses = bases.isEmpty ? ["Widget"] : bases
            default:
                continue
            }
            
            let customProps = getCustomProperties(for: rule, baseClasses: baseClasses)
            if !customProps.isEmpty {
                // Add ObjectProperty as default type for custom properties
                types.insert("ObjectProperty")
            }
        }
        
        return types
    }
    
    // MARK: - Class Generation
    
    private func generateClassForRule(_ rule: KvRule) throws -> [Statement] {
        let selector = rule.selector
        
        // Extract class name and base classes from selector
        let (className, baseClasses): (String, [String])
        switch selector {
        case .dynamicClass(let name, let bases):
            className = name
            baseClasses = bases.isEmpty ? ["Widget"] : bases
        case .name:
            // For simple name selectors, we don't generate a class
            // (this is a rule that applies to existing widget types)
            return []
        case .className, .multiple:
            // These selector types don't generate classes
            return []
        }
        
        // Generate class body with properties and children
        var body: [Statement] = []
        
        // Declare custom properties that need binding
        let customProps = getCustomProperties(for: rule, baseClasses: baseClasses)
        for propName in customProps.sorted() {
            // property_name = ObjectProperty(None)
            let propDecl = Assign(
                targets: [.name(makeName(propName))],
                value: .call(
                    Call(
                        fun: .name(makeName("ObjectProperty")),
                        args: [.constant(makeConstant(.none))],
                        keywords: [],
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                ),
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            body.append(.assign(propDecl))
        }
        
        // Add __init__ method if there are properties or children
        if !rule.properties.isEmpty || !rule.children.isEmpty {
            body.append(try generateInitMethod(rule))
        } else if body.isEmpty {
            // Empty class needs pass statement
            body.append(.pass(Pass(lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        }
        
        let bases: [PySwiftAST.Expression] = baseClasses.map { name in
            .name(makeName(name))
        }
        
        let classStmt = ClassDef(
            name: className,
            bases: bases,
            keywords: [],
            body: body,
            decoratorList: [],
            typeParams: [],
            lineno: 1,
            colOffset: 0,
            endLineno: nil,
            endColOffset: nil
        )
        
        return [.classDef(classStmt)]
    }
    
    private func getCustomProperties(for rule: KvRule, baseClasses: [String]) -> Swift.Set<String> {
        var customProps = Swift.Set<String>()
        
        for property in rule.properties {
            // Check if this property needs binding
            if needsBinding(property) {
                // Check if this property exists in any of the base classes
                let existsInBase = baseClasses.contains { baseClass in
                    KivyWidgetRegistry.getPropertyType(property.name, on: baseClass) != nil
                }
                
                // If it doesn't exist in base classes, it's a custom property
                if !existsInBase {
                    customProps.insert(property.name)
                }
            }
        }
        
        return customProps
    }
    
    private func generateInitMethod(_ rule: KvRule) throws -> Statement {
        var body: [Statement] = []
        
        // Call super().__init__(**kwargs)
        let superCall = PySwiftAST.Expression.call(
            Call(
                fun: .attribute(
                    Attribute(
                        value: .call(Call(
                            fun: .name(makeName("super")),
                            args: [],
                            keywords: [],
                            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                        )),
                        attr: "__init__",
                        ctx: .load,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                ),
                args: [],
                keywords: [Keyword(arg: nil, value: .name(makeName("kwargs")))],
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
        )
        body.append(.expr(Expr(value: superCall, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        
        // Get app instance if needed for bindings
        let hasAppBindings = rule.properties.contains { property in
            property.value.contains("app.")
        }
        
        if hasAppBindings {
            // app = App.get_running_app()
            let getAppCall = Assign(
                targets: [.name(makeName("app"))],
                value: .call(
                    Call(
                        fun: .attribute(
                            Attribute(
                                value: .name(makeName("App")),
                                attr: "get_running_app",
                                ctx: .load,
                                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                            )
                        ),
                        args: [],
                        keywords: [],
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                ),
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            body.append(.assign(getAppCall))
        }
        
        // Set properties (self.property = value)
        for property in rule.properties {
            if needsBinding(property) {
                // Generate binding with initial value and bind call
                body.append(try generatePropertyBinding(property))
            } else {
                // Simple assignment
                let assignment = Assign(
                    targets: [.attribute(
                        Attribute(
                            value: .name(makeName("self")),
                            attr: property.name,
                            ctx: .store,
                            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                        )
                    )],
                    value: try propertyValueToExpression(property),
                    typeComment: nil,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
                body.append(.assign(assignment))
            }
        }
        
        // Add bind() calls for reactive properties after all initialization
        for property in rule.properties {
            if needsBinding(property), let bindCall = generateBindingCall(property) {
                body.append(bindCall)
            }
        }
        
        // Add children (self.add_widget(...))
        for child in rule.children {
            let addWidgetCall = PySwiftAST.Expression.call(
                Call(
                    fun: .attribute(
                        Attribute(
                            value: .name(makeName("self")),
                            attr: "add_widget",
                            ctx: .load,
                            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                        )
                    ),
                    args: [try createChildWidget(child)],
                    keywords: [],
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            )
            body.append(.expr(Expr(value: addWidgetCall, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        }
        
        let initFunc = FunctionDef(
            name: "__init__",
            args: Arguments(
                posonlyArgs: [],
                args: [Arg(arg: "self", annotation: nil, typeComment: nil)],
                vararg: nil,
                kwonlyArgs: [],
                kwDefaults: [],
                kwarg: Arg(arg: "kwargs", annotation: nil, typeComment: nil),
                defaults: []
            ),
            body: body,
            decoratorList: [],
            returns: nil,
            typeComment: nil,
            typeParams: [],
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        return .functionDef(initFunc)
    }
    
    private func propertyValueToExpression(_ property: KvProperty) throws -> PySwiftAST.Expression {
        // Use the raw value string which has the actual source representation
        var valueStr = property.value.trimmingCharacters(in: .whitespaces)
        
        // Check if this is a binding expression (contains app., self., root., etc.)
        if valueStr.contains("app.") || valueStr.contains("self.") || valueStr.contains("root.") {
            // This needs to be a binding expression, return as-is for now
            // Will be handled by generatePropertyBinding
            return .constant(makeConstant(.string(valueStr)))
        }
        
        // Strip quotes from string values if present
        if (valueStr.hasPrefix("\"") && valueStr.hasSuffix("\"")) || 
           (valueStr.hasPrefix("'") && valueStr.hasSuffix("'")) {
            valueStr = String(valueStr.dropFirst().dropLast())
        }
        
        // Try to parse as number
        if let num = Double(valueStr) {
            return .constant(makeConstant(.float(num)))
        }
        
        // Check for booleans
        if valueStr == "True" {
            return .constant(makeConstant(.bool(true)))
        } else if valueStr == "False" {
            return .constant(makeConstant(.bool(false)))
        } else if valueStr == "None" {
            return .constant(makeConstant(.none))
        }
        
        // Check for tuples (contains comma but not inside quotes)
        if valueStr.contains(",") && !valueStr.hasPrefix("[") {
            // Parse as tuple: "0.5, 0.5" -> (0.5, 0.5)
            let parts = valueStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let exprs = parts.compactMap { part -> PySwiftAST.Expression? in
                if let num = Double(part) {
                    return .constant(makeConstant(.float(num)))
                }
                return nil
            }
            if !exprs.isEmpty {
                return .tuple(Tuple(elts: exprs, ctx: .load, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
            }
        }
        
        // Otherwise treat as string
        return .constant(makeConstant(.string(valueStr)))
    }
    
    private func needsBinding(_ property: KvProperty) -> Bool {
        let valueStr = property.value.trimmingCharacters(in: .whitespaces)
        return valueStr.contains("app.") || valueStr.contains("self.") || valueStr.contains("root.")
    }
    
    private func generatePropertyBinding(_ property: KvProperty, targetName: String = "self") throws -> Statement {
        let valueStr = property.value.trimmingCharacters(in: .whitespaces)
        
        // Parse the binding expression to extract the source object and property
        // e.g., "app.some_prop" -> source: app, prop: some_prop
        let parts = valueStr.split(separator: ".").map(String.init)
        guard parts.count >= 2 else {
            // Fallback to simple assignment
            let assignment = Assign(
                targets: [.attribute(
                    Attribute(
                        value: .name(makeName(targetName)),
                        attr: property.name,
                        ctx: .store,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )],
                value: .constant(makeConstant(.string(valueStr))),
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            return .assign(assignment)
        }
        
        let sourceObj = parts[0] // "app", "self", "root"
        let sourceProp = parts[1...].joined(separator: ".") // "some_prop" or nested like "obj.prop"
        
        // Generate: self.property = app.some_prop (initial value)
        let initialAssign = Assign(
            targets: [.attribute(
                Attribute(
                    value: .name(makeName(targetName)),
                    attr: property.name,
                    ctx: .store,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            )],
            value: .attribute(
                Attribute(
                    value: .name(makeName(sourceObj)),
                    attr: sourceProp,
                    ctx: .load,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            ),
            typeComment: nil,
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        return .assign(initialAssign)
    }
    
    private func generateBindingCall(_ property: KvProperty, targetName: String = "self") -> Statement? {
        let valueStr = property.value.trimmingCharacters(in: .whitespaces)
        
        // Parse the binding expression
        let parts = valueStr.split(separator: ".").map(String.init)
        guard parts.count >= 2 else { return nil }
        
        let sourceObj = parts[0]
        let sourceProp = parts[1]
        
        // Generate: app.bind(some_prop=self.setter('property'))
        // This is more efficient than using lambda with setattr
        
        let bindCall = PySwiftAST.Expression.call(
            Call(
                fun: .attribute(
                    Attribute(
                        value: .name(makeName(sourceObj)),
                        attr: "bind",
                        ctx: .load,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                ),
                args: [],
                keywords: [Keyword(
                    arg: sourceProp,
                    value: .call(
                        Call(
                            fun: .attribute(
                                Attribute(
                                    value: .name(makeName(targetName)),
                                    attr: "setter",
                                    ctx: .load,
                                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                                )
                            ),
                            args: [.constant(makeConstant(.string(property.name)))],
                            keywords: [],
                            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                        )
                    )
                )],
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
        )
        
        return .expr(Expr(value: bindCall, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
    }
    
    private func createChildWidget(_ widget: KvWidget) throws -> PySwiftAST.Expression {
        // Create widget instance: WidgetClass(**properties)
        var keywords: [Keyword] = []
        
        for property in widget.properties {
            let keyword = Keyword(
                arg: property.name,
                value: try propertyValueToExpression(property)
            )
            keywords.append(keyword)
        }
        
        return .call(
            Call(
                fun: .name(makeName(widget.name)),
                args: [],
                keywords: keywords,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
        )
    }
}
