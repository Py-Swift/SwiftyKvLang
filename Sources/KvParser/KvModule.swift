/// Root module representing a complete KV file
///
/// Corresponds to Parser class in parser.py, containing:
/// - directives: Preprocessor commands (#:kivy, #:import, etc.)
/// - rules: Widget class rules with selectors (<Button>, <.className>, etc.)
/// - templates: Dynamic class templates ([Name@Base])
/// - root: Optional root widget instance (widget without <>)
/// - dynamicClasses: Dynamic class definitions created with @ syntax
///
/// Reference: parser.py lines 468-498
public struct KvModule: KvNode, Sendable {
    public let directives: [KvDirective]
    public let rules: [KvRule]
    public let templates: [KvTemplate]
    public let root: KvWidget?
    public let dynamicClasses: [String: String]  // class name -> base classes
    
    // Position tracking
    public let line: Int
    public let column: Int
    public let endLine: Int?
    public let endColumn: Int?
    
    public init(
        directives: [KvDirective] = [],
        rules: [KvRule] = [],
        templates: [KvTemplate] = [],
        root: KvWidget? = nil,
        dynamicClasses: [String: String] = [:],
        line: Int = 1,
        column: Int = 0,
        endLine: Int? = nil,
        endColumn: Int? = nil
    ) {
        self.directives = directives
        self.rules = rules
        self.templates = templates
        self.root = root
        self.dynamicClasses = dynamicClasses
        self.line = line
        self.column = column
        self.endLine = endLine
        self.endColumn = endColumn
    }
}

extension KvModule: TreeDisplayable {
    public func treeDescription(indent: Int = 0) -> String {
        let prefix = String(repeating: "  ", count: indent)
        var result = "\(prefix)KvModule:\n"
        
        if !directives.isEmpty {
            result += "\(prefix)  Directives (\(directives.count)):\n"
            for directive in directives {
                result += directive.treeDescription(indent: indent + 2)
            }
        }
        
        if !rules.isEmpty {
            result += "\(prefix)  Rules (\(rules.count)):\n"
            for rule in rules {
                result += rule.treeDescription(indent: indent + 2)
            }
        }
        
        if !templates.isEmpty {
            result += "\(prefix)  Templates (\(templates.count)):\n"
            for template in templates {
                result += template.treeDescription(indent: indent + 2)
            }
        }
        
        if let root = root {
            result += "\(prefix)  Root Widget:\n"
            result += root.treeDescription(indent: indent + 2)
        }
        
        if !dynamicClasses.isEmpty {
            result += "\(prefix)  Dynamic Classes: \(dynamicClasses.keys.joined(separator: ", "))\n"
        }
        
        return result
    }
}
