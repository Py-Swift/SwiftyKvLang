/// KV Code Generator
///
/// Generates valid KV language source code from AST nodes.
/// Enables round-trip conversion: parse → AST → generate → parse
///
/// Example:
/// ```swift
/// let source = try KvCodeGen.generate(from: module)
/// ```
public struct KvCodeGen {
    
    // MARK: - Module Generation
    
    /// Generate KV source code from a module
    public static func generate(from module: KvModule, indent: String = "    ") -> String {
        var output = ""
        
        // Generate directives
        for directive in module.directives {
            output += generate(from: directive)
            output += "\n"
        }
        
        if !module.directives.isEmpty && (!module.rules.isEmpty || !module.templates.isEmpty || module.root != nil) {
            output += "\n"
        }
        
        // Generate rules
        for (index, rule) in module.rules.enumerated() {
            output += generate(from: rule, baseIndent: indent)
            if index < module.rules.count - 1 || !module.templates.isEmpty || module.root != nil {
                output += "\n"
            }
        }
        
        // Generate templates
        for (index, template) in module.templates.enumerated() {
            output += generate(from: template, baseIndent: indent)
            if index < module.templates.count - 1 || module.root != nil {
                output += "\n"
            }
        }
        
        // Generate root widget
        if let root = module.root {
            output += generate(from: root, level: 0, baseIndent: indent)
        }
        
        return output
    }
    
    // MARK: - Directive Generation
    
    private static func generate(from directive: KvDirective) -> String {
        switch directive {
        case .kivy(let version, _):
            return "#:kivy \(version)"
        case .import(let alias, let package, _):
            return "#:import \(alias) \(package)"
        case .include(let path, let force, _):
            return force ? "#:include <\(path)>" : "#:include \(path)"
        case .set(let name, let value, _):
            return "#:set \(name) \(value)"
        }
    }
    
    // MARK: - Rule Generation
    
    private static func generate(from rule: KvRule, baseIndent: String) -> String {
        var output = ""
        
        // Generate selector
        let avoidPrefix = rule.avoidPrevious ? "-" : ""
        output += "<\(avoidPrefix)\(generate(from: rule.selector))>\n"
        
        // Generate canvas.before
        if let canvasBefore = rule.canvasBefore {
            output += baseIndent + "canvas.before:\n"
            output += generate(from: canvasBefore, level: 2, baseIndent: baseIndent)
        }
        
        // Generate properties
        for property in rule.properties {
            output += baseIndent + generate(from: property)
        }
        
        // Generate canvas
        if let canvas = rule.canvas {
            output += baseIndent + "canvas:\n"
            output += generate(from: canvas, level: 2, baseIndent: baseIndent)
        }
        
        // Generate canvas.after
        if let canvasAfter = rule.canvasAfter {
            output += baseIndent + "canvas.after:\n"
            output += generate(from: canvasAfter, level: 2, baseIndent: baseIndent)
        }
        
        // Generate event handlers
        for handler in rule.handlers {
            output += baseIndent + generate(from: handler)
        }
        
        // Generate child widgets
        for child in rule.children {
            output += generate(from: child, level: 1, baseIndent: baseIndent)
        }
        
        return output
    }
    
    // MARK: - Selector Generation
    
    private static func generate(from selector: KvSelector) -> String {
        switch selector {
        case .name(let name):
            return name
        case .className(let name):
            return ".\(name)"
        case .multiple(let selectors):
            return selectors.map { generate(from: $0) }.joined(separator: ",")
        case .dynamicClass(let name, let bases):
            let basesStr = bases.joined(separator: "+")
            return "\(name)@\(basesStr)"
        }
    }
    
    // MARK: - Template Generation
    
    private static func generate(from template: KvTemplate, baseIndent: String) -> String {
        var output = ""
        
        // Generate template header
        let basesStr = template.baseClasses.joined(separator: "+")
        output += "[\(template.name)@\(basesStr)]:\n"
        
        // Generate rule body
        let rule = template.rule
        
        // Generate canvas.before
        if let canvasBefore = rule.canvasBefore {
            output += baseIndent + "canvas.before:\n"
            output += generate(from: canvasBefore, level: 2, baseIndent: baseIndent)
        }
        
        // Generate properties
        for property in rule.properties {
            output += baseIndent + generate(from: property)
        }
        
        // Generate canvas
        if let canvas = rule.canvas {
            output += baseIndent + "canvas:\n"
            output += generate(from: canvas, level: 2, baseIndent: baseIndent)
        }
        
        // Generate canvas.after
        if let canvasAfter = rule.canvasAfter {
            output += baseIndent + "canvas.after:\n"
            output += generate(from: canvasAfter, level: 2, baseIndent: baseIndent)
        }
        
        // Generate event handlers
        for handler in rule.handlers {
            output += baseIndent + generate(from: handler)
        }
        
        // Generate child widgets
        for child in rule.children {
            output += generate(from: child, level: 1, baseIndent: baseIndent)
        }
        
        return output
    }
    
    // MARK: - Widget Generation
    
    private static func generate(from widget: KvWidget, level: Int, baseIndent: String) -> String {
        var output = ""
        let indent = String(repeating: baseIndent, count: level)
        
        // Generate widget name
        output += indent + "\(widget.name):\n"
        
        // Generate id if present
        if let id = widget.id {
            output += indent + baseIndent + "id: \(id)\n"
        }
        
        // Generate canvas.before
        if let canvasBefore = widget.canvasBefore {
            output += indent + baseIndent + "canvas.before:\n"
            output += generate(from: canvasBefore, level: level + 2, baseIndent: baseIndent)
        }
        
        // Generate properties
        for property in widget.properties {
            output += indent + baseIndent + generate(from: property)
        }
        
        // Generate canvas
        if let canvas = widget.canvas {
            output += indent + baseIndent + "canvas:\n"
            output += generate(from: canvas, level: level + 2, baseIndent: baseIndent)
        }
        
        // Generate canvas.after
        if let canvasAfter = widget.canvasAfter {
            output += indent + baseIndent + "canvas.after:\n"
            output += generate(from: canvasAfter, level: level + 2, baseIndent: baseIndent)
        }
        
        // Generate event handlers
        for handler in widget.handlers {
            output += indent + baseIndent + generate(from: handler)
        }
        
        // Generate child widgets
        for child in widget.children {
            output += generate(from: child, level: level + 1, baseIndent: baseIndent)
        }
        
        return output
    }
    
    // MARK: - Property Generation
    
    private static func generate(from property: KvProperty) -> String {
        return "\(property.name): \(property.value)\n"
    }
    
    // MARK: - Canvas Generation
    
    private static func generate(from canvas: KvCanvas, level: Int, baseIndent: String) -> String {
        var output = ""
        let indent = String(repeating: baseIndent, count: level)
        
        for instruction in canvas.instructions {
            output += indent + generate(from: instruction, level: level, baseIndent: baseIndent)
        }
        
        return output
    }
    
    // MARK: - Canvas Instruction Generation
    
    private static func generate(from instruction: KvCanvasInstruction, level: Int, baseIndent: String) -> String {
        var output = ""
        
        // Generate instruction type
        output += "\(instruction.instructionType):\n"
        
        // Generate properties
        if !instruction.properties.isEmpty {
            let indent = String(repeating: baseIndent, count: level + 1)
            for property in instruction.properties {
                output += indent + generate(from: property)
            }
        }
        
        return output
    }
}

// MARK: - Module Extension

extension KvModule {
    /// Generate KV source code from this module
    public func generate(indent: String = "    ") -> String {
        return KvCodeGen.generate(from: self, indent: indent)
    }
}
