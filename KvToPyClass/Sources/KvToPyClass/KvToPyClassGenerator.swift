import Foundation
import KvParser
import PySwiftAST
import PySwiftCodeGen
import PyFormatters

// MARK: - Property Expression Visitor

/// Visitor to extract watched keys from property value expressions (especially f-strings)
class PropertyExpressionVisitor: ExpressionVisitor {
    typealias ExpressionResult = Void
    
    var watchedKeys: [[String]] = []
    
    func visitAttribute(_ node: Attribute) {
        // Extract obj.attr patterns like app.title, self.width
        if case .name(let name) = node.value {
            watchedKeys.append([name.id, node.attr])
        }
        // Recursively visit the value expression
        visitExpression(node.value)
    }
    
    func visitJoinedStr(_ node: JoinedStr) {
        // Visit all FormattedValue expressions in the f-string
        for value in node.values {
            visitExpression(value)
        }
    }
    
    func visitFormattedValue(_ node: FormattedValue) {
        // Visit the expression inside the formatted value
        visitExpression(node.value)
    }
    
    func visitCall(_ node: Call) {
        // Handle str(app.prop) patterns
        if case .name(let funcName) = node.fun, funcName.id == "str" {
            // Visit arguments to extract watched keys
            for arg in node.args {
                visitExpression(arg)
            }
        }
        // Visit the function expression and arguments
        visitExpression(node.fun)
        for arg in node.args {
            visitExpression(arg)
        }
    }
    
    // MARK: - Required Protocol Methods (no-op implementations)
    
    func visitConstant(_ node: Constant) {}
    func visitList(_ node: List) {}
    func visitTuple(_ node: Tuple) {}
    func visitDict(_ node: Dict) {}
    func visitSet(_ node: Set) {}
    func visitName(_ node: Name) {}
    func visitSubscript(_ node: Subscript) {}
    func visitStarred(_ node: Starred) {}
    func visitBinOp(_ node: BinOp) {}
    func visitUnaryOp(_ node: UnaryOp) {}
    func visitBoolOp(_ node: BoolOp) {}
    func visitCompare(_ node: Compare) {}
    func visitLambda(_ node: Lambda) {}
    func visitListComp(_ node: ListComp) {}
    func visitSetComp(_ node: SetComp) {}
    func visitDictComp(_ node: DictComp) {}
    func visitGeneratorExp(_ node: GeneratorExp) {}
    func visitIfExp(_ node: IfExp) {}
    func visitNamedExpr(_ node: NamedExpr) {}
    func visitYield(_ node: Yield) {}
    func visitYieldFrom(_ node: YieldFrom) {}
    func visitAwait(_ node: Await) {}
    func visitSlice(_ node: Slice) {}
}

// MARK: - Expression Replacement Helper

/// Replace an attribute access (obj.attr) with a name reference in an expression tree
private func replaceAttributeWithName(_ expr: PySwiftAST.Expression, object: String, attr: String, replacement: String) -> PySwiftAST.Expression {
    switch expr {
    case .attribute(let attrNode):
        // Check if this is the attribute we want to replace
        if case .name(let nameNode) = attrNode.value, nameNode.id == object, attrNode.attr == attr {
            // Replace with name reference
            return .name(Name(id: replacement, ctx: .load, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
        }
        return expr
        
    case .joinedStr(let joinedStr):
        // Recursively process f-string values
        let newValues = joinedStr.values.map { replaceAttributeWithName($0, object: object, attr: attr, replacement: replacement) }
        return .joinedStr(JoinedStr(values: newValues, lineno: joinedStr.lineno, colOffset: joinedStr.colOffset, endLineno: joinedStr.endLineno, endColOffset: joinedStr.endColOffset))
        
    case .formattedValue(let formattedValue):
        // Recursively process the value inside {}
        let newValue = replaceAttributeWithName(formattedValue.value, object: object, attr: attr, replacement: replacement)
        return .formattedValue(FormattedValue(value: newValue, conversion: formattedValue.conversion, formatSpec: formattedValue.formatSpec, lineno: formattedValue.lineno, colOffset: formattedValue.colOffset, endLineno: formattedValue.endLineno, endColOffset: formattedValue.endColOffset))
        
    case .call(let call):
        // Recursively process function and arguments
        let newFun = replaceAttributeWithName(call.fun, object: object, attr: attr, replacement: replacement)
        let newArgs = call.args.map { replaceAttributeWithName($0, object: object, attr: attr, replacement: replacement) }
        return .call(Call(fun: newFun, args: newArgs, keywords: call.keywords, lineno: call.lineno, colOffset: call.colOffset, endLineno: call.endLineno, endColOffset: call.endColOffset))
        
    default:
        // For other expression types, return as-is
        return expr
    }
}

/// Generates Python class code from KV language rules
///
/// Kivy's Builder dynamically applies KV rules to widgets at runtime.
/// This generator instead creates equivalent Python class definitions that
/// produce the same widget tree structure and property bindings.
public struct KvToPyClassGenerator {
    
    private let module: KvModule
    private let pythonClasses: [PythonClassInfo]
    
    public init(module: KvModule, pythonClasses: [PythonClassInfo] = []) {
        self.module = module
        self.pythonClasses = pythonClasses
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
        
        // Apply Black formatter for proper blank line formatting
        let formatter = BlackFormatter()
        let formattedModule = formatter.formatDeep(pyModule)
        
        let code = try formatModule(formattedModule)
        
        return code
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
    
    /// Collect all widget types used in the module (excluding custom widgets defined in this module)
    private func collectWidgetTypes() -> Swift.Set<String> {
        var types = Swift.Set<String>()
        
        // First, collect all custom widget names defined in this module
        var customWidgets = Swift.Set<String>()
        for rule in module.rules {
            switch rule.selector {
            case .dynamicClass(let name, _):
                customWidgets.insert(name)
            case .name(let name):
                customWidgets.insert(name)
            default:
                break
            }
        }
        
        // Now collect widget types, excluding custom ones
        for rule in module.rules {
            switch rule.selector {
            case .dynamicClass(_, let bases):
                // Only add base classes that aren't custom widgets
                for base in bases where !customWidgets.contains(base) {
                    types.insert(base)
                }
            case .name(_):
                // Skip this name itself since it's a custom widget
                break
            default:
                break
            }
            // Collect from children, excluding custom widgets
            collectTypesFromChildren(rule.children, into: &types, excluding: customWidgets)
        }
        
        return types
    }
    
    private func collectTypesFromChildren(_ children: [KvWidget], into types: inout Swift.Set<String>, excluding customWidgets: Swift.Set<String>) {
        for child in children {
            // Only add if it's not a custom widget
            if !customWidgets.contains(child.name) {
                types.insert(child.name)
            }
            collectTypesFromChildren(child.children, into: &types, excluding: customWidgets)
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
        
        // Import App if any bindings use 'app' (check both rule properties and child widgets)
        let needsApp = module.rules.contains { rule in
            rule.properties.contains { property in
                property.value.contains("app.")
            } || rule.handlers.contains { handler in
                handler.value.contains("app.")
            } || hasAppBindingsInChildren(rule.children)
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
            // Check if we have Python class info for this class
            if let pythonClass = pythonClasses.first(where: { $0.name == name }) {
                // Use base classes from Python code if they exist
                baseClasses = pythonClass.baseClasses.isEmpty ? (bases.isEmpty ? ["Widget"] : bases) : pythonClass.baseClasses
            } else {
                baseClasses = bases.isEmpty ? ["Widget"] : bases
            }
        case .name(let name):
            // For simple name selectors, check Python code first
            className = name
            if let pythonClass = pythonClasses.first(where: { $0.name == name }) {
                baseClasses = pythonClass.baseClasses.isEmpty ? ["Widget"] : pythonClass.baseClasses
            } else {
                baseClasses = ["Widget"]
            }
        case .className, .multiple:
            // These selector types don't generate classes
            return []
        }
        
        // Generate class body with properties and children
        var body: [Statement] = []
        
        // Add initial blank line at the start of class body
        body.append(.blank(1))
        
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
            body.append(try generateInitMethod(rule, baseClasses: baseClasses, className: className))
        } else if body.isEmpty {
            // Empty class needs pass statement
            body.append(.pass(Pass(lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        }
        
        // Add event handler methods
        for handler in rule.handlers {
            if let handlerMethod = try generateEventHandlerMethod(handler) {
                body.append(handlerMethod)
            }
        }
        
        // Add any additional methods from Python code (as AST nodes)
        if let pythonClass = pythonClasses.first(where: { $0.name == className }) {
            for method in pythonClass.methods {
                // Directly append the method AST nodes from the parsed Python code
                body.append(method)
            }
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
    
    /// Recursively check if any child widgets use app bindings
    private func hasAppBindingsInChildren(_ children: [KvWidget]) -> Bool {
        for child in children {
            // Check child's properties
            for property in child.properties {
                if property.value.contains("app.") {
                    return true
                }
            }
            // Check child's handlers
            for handler in child.handlers {
                if handler.value.contains("app.") {
                    return true
                }
            }
            // Recursively check nested children
            if hasAppBindingsInChildren(child.children) {
                return true
            }
        }
        return false
    }
    
    private func generateInitMethod(_ rule: KvRule, baseClasses: [String], className: String) throws -> Statement {
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
        
        // Get app instance if needed for bindings (check both rule properties and child widgets)
        let hasAppBindings = rule.properties.contains { property in
            property.value.contains("app.")
        } || rule.handlers.contains { handler in
            handler.value.contains("app.")
        } || hasAppBindingsInChildren(rule.children)
        
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
        // Event handlers are in rule.handlers, not rule.properties
        for property in rule.properties {
            if needsBinding(property) {
                // Generate binding with initial value and bind call
                body.append(try generatePropertyBinding(property))
            } else {
                // Simple assignment
                let widgetName = baseClasses.first ?? "Widget"
                let assignment = Assign(
                    targets: [.attribute(
                        Attribute(
                            value: .name(makeName("self")),
                            attr: property.name,
                            ctx: .store,
                            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                        )
                    )],
                    value: try propertyValueToExpression(property, widgetName: widgetName),
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
        
        // Add event handler bindings (on_press, on_release, etc.)
        for handler in rule.handlers {
            if let bindCall = generateEventHandlerBinding(handler) {
                body.append(bindCall)
            }
        }
        
        // Add children with proper nesting and id handling
        for child in rule.children {
            body.append(contentsOf: try createAndAddChildWidget(child, parentName: "self"))
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
    
    private func propertyValueToExpression(_ property: KvProperty, widgetName: String = "Widget") throws -> PySwiftAST.Expression {
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
        
        // Check what type this property should be based on the widget registry
        let propertyType = KivyWidgetRegistry.getPropertyType(property.name, on: widgetName)
        
        // Handle list/tuple properties (ReferenceListProperty, ListProperty, VariableListProperty)
        if propertyType == .referenceListProperty || 
           propertyType == .listProperty || 
           propertyType == .variableListProperty {
            // Parse as tuple/list: "None , None" -> (None, None) or "0.5, 0.5" -> (0.5, 0.5)
            if valueStr.contains(",") {
                let parts = valueStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let exprs = parts.map { part -> PySwiftAST.Expression in
                    if part == "None" {
                        return .constant(makeConstant(.none))
                    } else if let num = Double(part) {
                        return .constant(makeConstant(.float(num)))
                    } else if part == "True" {
                        return .constant(makeConstant(.bool(true)))
                    } else if part == "False" {
                        return .constant(makeConstant(.bool(false)))
                    } else {
                        return .constant(makeConstant(.string(part)))
                    }
                }
                return .tuple(Tuple(elts: exprs, ctx: .load, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
            }
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
                if part == "None" {
                    return .constant(makeConstant(.none))
                } else if let num = Double(part) {
                    return .constant(makeConstant(.float(num)))
                } else if part == "True" {
                    return .constant(makeConstant(.bool(true)))
                } else if part == "False" {
                    return .constant(makeConstant(.bool(false)))
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
        // Use the pre-computed watchedKeys from the parser instead of manual string parsing
        if let watchedKeys = property.watchedKeys, !watchedKeys.isEmpty {
            return true
        }
        return false
    }
    
    /// Parse property value as Python expression and extract watched keys using visitor
    private func parsePropertyExpression(_ property: KvProperty) -> (PySwiftAST.Expression?, [[String]]) {
        let valueStr = property.value.trimmingCharacters(in: .whitespaces)
        
        // Try to parse as Python expression by wrapping it in an assignment
        do {
            let code = "_tmp = \(valueStr)"
            let module = try parsePython(code)
            
            // Extract the expression from the assignment
            if case .module(let statements) = module,
               let firstStmt = statements.first,
               case .assign(let assign) = firstStmt {
                let expr = assign.value
                
                // Use visitor to extract watched keys
                let visitor = PropertyExpressionVisitor()
                visitor.visitExpression(expr)
                return (expr, visitor.watchedKeys)
            }
        } catch {
            // If parsing fails, fall back to the pre-computed watchedKeys
            return (nil, property.watchedKeys ?? [])
        }
        
        return (nil, property.watchedKeys ?? [])
    }
    
    private func isEventHandler(_ property: KvProperty) -> Bool {
        // Event handlers in Kivy start with "on_"
        return property.name.hasPrefix("on_")
    }
    
    private func generatePropertyBinding(_ property: KvProperty, targetName: String = "self") throws -> Statement {
        let valueStr = property.value.trimmingCharacters(in: .whitespaces)
        
        // Parse the expression and extract watched keys using visitor
        let (parsedExpr, watchedKeys) = parsePropertyExpression(property)
        
        // For simple property bindings like "app.title" use direct assignment
        // For complex expressions like f-strings or str() use the parsed expression
        let isSimpleBinding = watchedKeys.count == 1 && 
                             watchedKeys[0].count == 2 && 
                             !valueStr.contains("(") && 
                             !valueStr.hasPrefix("f\"") && 
                             !valueStr.hasPrefix("f'")
        
        if isSimpleBinding, let firstKey = watchedKeys.first {
            // Simple case: app.some_prop -> self.property = app.some_prop
            let sourceObj = firstKey[0]
            let sourceProp = firstKey[1]
            
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
        } else if let expr = parsedExpr {
            // Complex expression (f-string, str(), etc.): use the parsed AST expression
            let initialAssign = Assign(
                targets: [.attribute(
                    Attribute(
                        value: .name(makeName(targetName)),
                        attr: property.name,
                        ctx: .store,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )],
                value: expr,
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            
            return .assign(initialAssign)
        } else {
            // Fallback to string constant if parsing failed
            let initialAssign = Assign(
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
            
            return .assign(initialAssign)
        }
    }
    
    private func generateBindingCall(_ property: KvProperty, targetName: String = "self") -> Statement? {
        guard let watchedKeys = property.watchedKeys, !watchedKeys.isEmpty else {
            return nil
        }
        
        // For simple bindings (single watched key, direct property access)
        if watchedKeys.count == 1, watchedKeys[0].count == 2 {
            let sourceObj = watchedKeys[0][0]
            let sourceProp = watchedKeys[0][1]
            
            // Generate: app.bind(prop=self.setter('property'))
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
        
        // For complex expressions (f-strings, multiple watched keys)
        // We need to bind to ALL watched properties and re-evaluate the expression
        // app.bind(title=lambda *args: setattr(self, 'text', f"{app.title}-{app.version}"))
        // app.bind(version=lambda *args: setattr(self, 'text', f"{app.title}-{app.version}"))
        
        // TODO: Generate bindings for each watched key that re-evaluates the full expression
        // For now, just bind to the first one
        if let firstKey = watchedKeys.first, firstKey.count == 2 {
            let sourceObj = firstKey[0]
            let sourceProp = firstKey[1]
            
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
        
        return nil
    }
    
    /// Generate property binding for child widgets
    /// Similar to generateBindingCall but for child widget properties
    /// Returns multiple bind() statements - one for each watched key
    private func generateChildPropertyBinding(_ property: KvProperty, widgetVarName: String) -> [Statement] {
        guard let watchedKeys = property.watchedKeys, !watchedKeys.isEmpty else {
            return []
        }
        
        // Parse the expression to get the AST
        let (parsedExpr, _) = parsePropertyExpression(property)
        
        // For simple bindings (single watched key, direct property access)
        if watchedKeys.count == 1, watchedKeys[0].count == 2, parsedExpr != nil {
            let sourceObj = watchedKeys[0][0]
            let sourceProp = watchedKeys[0][1]
            
            // Generate: app.bind(prop=widget.setter('property'))
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
                                        value: .name(makeName(widgetVarName)),
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
            
            return [.expr(Expr(value: bindCall, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))]
        }
        
        // For complex expressions (f-strings, multiple watched keys)
        // Generate bind() for each watched key with a lambda that re-evaluates the full expression
        
        if let expr = parsedExpr, !watchedKeys.isEmpty {
            var bindStatements: [Statement] = []
            
            // Generate bind() for EACH watched key
            for watchedKey in watchedKeys {
                guard watchedKey.count == 2 else { continue }
                let sourceObj = watchedKey[0]
                let sourceProp = watchedKey[1]
                
                // Generate parameter name: app.title -> app_title
                let paramName = "\(sourceObj)_\(sourceProp)"
                
                // Replace the watched attribute (app.title) with the parameter name in the expression
                let modifiedExpr = replaceAttributeWithName(expr, object: sourceObj, attr: sourceProp, replacement: paramName)
                
                // Create lambda: lambda instance, param_name: setattr(widget, 'property', expression)
                let lambdaBody = PySwiftAST.Expression.call(
                    Call(
                        fun: .name(makeName("setattr")),
                        args: [
                            .name(makeName(widgetVarName)),
                            .constant(makeConstant(.string(property.name))),
                            modifiedExpr
                        ],
                        keywords: [],
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )
                
                let lambda = Lambda(
                    args: Arguments(
                        posonlyArgs: [],
                        args: [
                            Arg(arg: "instance", annotation: nil, typeComment: nil),
                            Arg(arg: paramName, annotation: nil, typeComment: nil)
                        ],
                        vararg: nil,
                        kwonlyArgs: [],
                        kwDefaults: [],
                        kwarg: nil,
                        defaults: []
                    ),
                    body: lambdaBody,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
                
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
                        keywords: [Keyword(arg: sourceProp, value: .lambda(lambda))],
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )
                
                bindStatements.append(.expr(Expr(value: bindCall, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
            }
            
            return bindStatements
        }
        
        return []
    }
    
    /// Generate binding for event handlers (on_press, on_release, etc.)
    /// Returns: self.bind(on_press=self._on_press_handler)
    private func generateEventHandlerBinding(_ property: KvProperty) -> Statement? {
        guard isEventHandler(property) else { return nil }
        
        let handlerName = "_\(property.name)_handler"
        
        // self.bind(on_event=self._on_event_handler)
        let bindCall = Call(
            fun: .attribute(
                Attribute(
                    value: .name(makeName("self")),
                    attr: "bind",
                    ctx: .load,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            ),
            args: [],
            keywords: [Keyword(
                arg: property.name,
                value: .attribute(
                    Attribute(
                        value: .name(makeName("self")),
                        attr: handlerName,
                        ctx: .load,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )
            )],
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        return .expr(Expr(value: .call(bindCall), lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
    }
    
    /// Generate an event handler method
    /// Returns: def _on_event_handler(self, instance): <handler code>
    private func generateEventHandlerMethod(_ property: KvProperty) throws -> Statement? {
        guard isEventHandler(property) else { return nil }
        
        let handlerName = "_\(property.name)_handler"
        
        // Parse the handler code
        let handlerCode = property.value.trimmingCharacters(in: .whitespaces)
        
        // Try to parse as Python expression/statement
        var body: [Statement] = []
        
        // For now, handle simple cases:
        // 1. Function calls like "app.handle_click()" or "print('hello')"
        // 2. Simple expressions
        
        if handlerCode.contains("(") && handlerCode.contains(")") {
            // Looks like a function call
            do {
                let expr = try parsePythonExpression(handlerCode)
                body.append(.expr(Expr(value: expr, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
            } catch {
                // If parsing fails, add a pass statement
                body.append(.pass(Pass(lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
            }
        } else {
            // Simple expression or pass
            body.append(.pass(Pass(lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        }
        
        let functionDef = FunctionDef(
            name: handlerName,
            args: Arguments(
                posonlyArgs: [],
                args: [
                    Arg(arg: "self", annotation: nil, typeComment: nil),
                    Arg(arg: "instance", annotation: nil, typeComment: nil)
                ],
                vararg: nil,
                kwonlyArgs: [],
                kwDefaults: [],
                kwarg: nil,
                defaults: []
            ),
            body: body,
            decoratorList: [],
            returns: nil,
            typeComment: nil,
            typeParams: [],
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        return .functionDef(functionDef)
    }
    
    /// Parse a Python expression from string
    private func parsePythonExpression(_ code: String) throws -> PySwiftAST.Expression {
        // Handle common patterns
        
        // print("text")
        if code.hasPrefix("print(") && code.hasSuffix(")") {
            let content = String(code.dropFirst(6).dropLast(1))
            let arg: PySwiftAST.Expression
            
            // Check if it's a string literal
            if content.hasPrefix("\"") && content.hasSuffix("\"") {
                let stringContent = String(content.dropFirst(1).dropLast(1))
                arg = .constant(makeConstant(.string(stringContent)))
            } else if content.hasPrefix("'") && content.hasSuffix("'") {
                let stringContent = String(content.dropFirst(1).dropLast(1))
                arg = .constant(makeConstant(.string(stringContent)))
            } else {
                // It's an expression
                arg = try parsePythonExpression(content)
            }
            
            return .call(
                Call(
                    fun: .name(makeName("print")),
                    args: [arg],
                    keywords: [],
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            )
        }
        
        // app.method(), self.method(), or root.method()
        if code.contains(".") && code.contains("(") {
            let parts = code.components(separatedBy: "(")
            let callPart = parts[0]
            let dotParts = callPart.components(separatedBy: ".")
            
            if dotParts.count == 2 {
                var obj = dotParts[0]
                let method = dotParts[1]
                
                // In Kv language, 'root' refers to the root widget of the current rule
                // In generated Python code, that's 'self' (the class instance)
                if obj == "root" {
                    obj = "self"
                }
                
                return .call(
                    Call(
                        fun: .attribute(
                            Attribute(
                                value: .name(makeName(obj)),
                                attr: method,
                                ctx: .load,
                                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                            )
                        ),
                        args: [],
                        keywords: [],
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )
            }
        }
        
        // Fallback: return a name
        return .name(makeName(code))
    }
    
    /// Generate binding for event handlers on child widgets
    /// Returns: widget.bind(on_press=lambda instance: handler_code)
    private func generateChildWidgetEventBinding(_ handler: KvProperty, widgetVarName: String) throws -> Statement? {
        let handlerCode = handler.value.trimmingCharacters(in: .whitespaces)
        
        // Parse the handler expression
        let handlerExpr = try parsePythonExpression(handlerCode)
        
        // Create lambda: lambda instance: handler_expression
        let lambdaFunc = Lambda(
            args: Arguments(
                posonlyArgs: [],
                args: [Arg(arg: "instance", annotation: nil, typeComment: nil)],
                vararg: nil,
                kwonlyArgs: [],
                kwDefaults: [],
                kwarg: nil,
                defaults: []
            ),
            body: handlerExpr,
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        // widget.bind(on_event=lambda_func)
        let bindCall = Call(
            fun: .attribute(
                Attribute(
                    value: .name(makeName(widgetVarName)),
                    attr: "bind",
                    ctx: .load,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            ),
            args: [],
            keywords: [Keyword(
                arg: handler.name,
                value: .lambda(lambdaFunc)
            )],
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        
        return .expr(Expr(value: .call(bindCall), lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))
    }
    
    /// Create and add a child widget with proper handling of nested children and ids
    /// Returns statements that create the widget, store it if it has an id, add its children, and add it to parent
    private func createAndAddChildWidget(_ widget: KvWidget, parentName: String, widgetVarName: String? = nil) throws -> [Statement] {
        var statements: [Statement] = []
        
        // Get the widget id directly from the widget struct (not from properties)
        let widgetId = widget.id
        
        // Generate a variable name for this widget (use id if available, otherwise generate one)
        let varName = widgetVarName ?? (widgetId ?? "widget_\(UUID().uuidString.prefix(8))")
        
        // Separate properties that need binding from static ones
        var staticProperties: [KvProperty] = []
        var bindingProperties: [KvProperty] = []
        
        for property in widget.properties {
            if needsBinding(property) {
                bindingProperties.append(property)
            } else {
                staticProperties.append(property)
            }
        }
        
        // Create widget instance with only static properties
        var keywords: [Keyword] = []
        for property in staticProperties {
            let keyword = Keyword(
                arg: property.name,
                value: try propertyValueToExpression(property, widgetName: widget.name)
            )
            keywords.append(keyword)
        }
        
        let widgetCreation = Assign(
            targets: [.name(makeName(varName))],
            value: .call(
                Call(
                    fun: .name(makeName(widget.name)),
                    args: [],
                    keywords: keywords,
                    lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                )
            ),
            typeComment: nil,
            lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
        )
        statements.append(.assign(widgetCreation))
        
        // Set binding properties and create bind() calls
        for property in bindingProperties {
            // Parse the expression to get the AST
            let (parsedExpr, _) = parsePropertyExpression(property)
            
            // Use parsed expression if available, otherwise fallback to simple conversion
            let valueExpr: PySwiftAST.Expression
            if let expr = parsedExpr {
                valueExpr = expr
            } else {
                valueExpr = try propertyValueToExpression(property, widgetName: widget.name)
            }
            
            // Set initial value: widget.property = expression
            let setProperty = Assign(
                targets: [.attribute(
                    Attribute(
                        value: .name(makeName(varName)),
                        attr: property.name,
                        ctx: .store,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )],
                value: valueExpr,
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            statements.append(.assign(setProperty))
            
            // Create bind() calls for this property (one for each watched key)
            let bindingStmts = generateChildPropertyBinding(property, widgetVarName: varName)
            statements.append(contentsOf: bindingStmts)
        }
        
        // If widget has an id, store it in self.ids
        if let widgetId = widgetId {
            let storeInIds = Assign(
                targets: [.attribute(
                    Attribute(
                        value: .attribute(
                            Attribute(
                                value: .name(makeName("self")),
                                attr: "ids",
                                ctx: .load,
                                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                            )
                        ),
                        attr: widgetId,
                        ctx: .store,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                )],
                value: .name(makeName(varName)),
                typeComment: nil,
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
            statements.append(.assign(storeInIds))
        }
        
        // Add children to this widget recursively
        for child in widget.children {
            statements.append(contentsOf: try createAndAddChildWidget(child, parentName: varName))
        }
        
        // Bind event handlers for this widget
        for handler in widget.handlers {
            // Generate inline handler binding: widget.bind(on_press=lambda instance: print("hello"))
            if let bindStmt = try generateChildWidgetEventBinding(handler, widgetVarName: varName) {
                statements.append(bindStmt)
            }
        }
        
        // Add this widget to parent
        let addToParent = PySwiftAST.Expression.call(
            Call(
                fun: .attribute(
                    Attribute(
                        value: .name(makeName(parentName)),
                        attr: "add_widget",
                        ctx: .load,
                        lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
                    )
                ),
                args: [.name(makeName(varName))],
                keywords: [],
                lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil
            )
        )
        statements.append(.expr(Expr(value: addToParent, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil)))
        
        return statements
    }
    
    private func createChildWidget(_ widget: KvWidget) throws -> PySwiftAST.Expression {
        // Create widget instance: WidgetClass(**properties)
        var keywords: [Keyword] = []
        
        for property in widget.properties {
            let keyword = Keyword(
                arg: property.name,
                value: try propertyValueToExpression(property, widgetName: widget.name)
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
