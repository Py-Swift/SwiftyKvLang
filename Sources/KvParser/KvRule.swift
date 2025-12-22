/// Widget class rule definition
///
/// Represents a rule that applies to widget classes, defining their properties,
/// children, canvas instructions, and event handlers.
///
/// Example from style.kv:
/// ```
/// <Button>:
///     background_normal: 'atlas://...'
///     canvas:
///         Color:
///             rgba: self.color
/// ```
///
/// Reference: parser.py lines 303-362 (ParserRule class)
public struct KvRule: KvNode, Sendable {
    /// Selector determining which widgets this rule applies to
    public let selector: KvSelector
    
    /// Properties defined in this rule
    public let properties: [KvProperty]
    
    /// Child widgets to create
    public let children: [KvWidget]
    
    /// Canvas instructions rendered before widget
    public let canvasBefore: KvCanvas?
    
    /// Main canvas instructions
    public let canvas: KvCanvas?
    
    /// Canvas instructions rendered after widget
    public let canvasAfter: KvCanvas?
    
    /// Event handlers (properties starting with on_)
    public let handlers: [KvProperty]
    
    /// If true, avoid applying previous rules for this selector
    /// Indicated by - prefix in selector: <-Button>
    public let avoidPrevious: Bool
    
    // Position tracking
    public let line: Int
    public let column: Int
    public let endLine: Int?
    public let endColumn: Int?
    
    public init(
        selector: KvSelector,
        properties: [KvProperty] = [],
        children: [KvWidget] = [],
        canvasBefore: KvCanvas? = nil,
        canvas: KvCanvas? = nil,
        canvasAfter: KvCanvas? = nil,
        handlers: [KvProperty] = [],
        avoidPrevious: Bool = false,
        line: Int,
        column: Int = 0,
        endLine: Int? = nil,
        endColumn: Int? = nil
    ) {
        self.selector = selector
        self.properties = properties
        self.children = children
        self.canvasBefore = canvasBefore
        self.canvas = canvas
        self.canvasAfter = canvasAfter
        self.handlers = handlers
        self.avoidPrevious = avoidPrevious
        self.line = line
        self.column = column
        self.endLine = endLine
        self.endColumn = endColumn
    }
}

extension KvRule: TreeDisplayable {
    public func treeDescription(indent: Int = 0) -> String {
        let prefix = String(repeating: "  ", count: indent)
        let avoid = avoidPrevious ? "-" : ""
        var result = "\(prefix)<\(avoid)\(selector.primaryName)> [line \(line)]:\n"
        
        if !properties.isEmpty {
            result += "\(prefix)  Properties (\(properties.count)):\n"
            for prop in properties {
                result += prop.treeDescription(indent: indent + 2)
            }
        }
        
        if !handlers.isEmpty {
            result += "\(prefix)  Handlers (\(handlers.count)):\n"
            for handler in handlers {
                result += handler.treeDescription(indent: indent + 2)
            }
        }
        
        if let canvas = canvasBefore {
            result += "\(prefix)  canvas.before:\n"
            result += canvas.treeDescription(indent: indent + 2)
        }
        
        if let canvas = canvas {
            result += "\(prefix)  canvas:\n"
            result += canvas.treeDescription(indent: indent + 2)
        }
        
        if let canvas = canvasAfter {
            result += "\(prefix)  canvas.after:\n"
            result += canvas.treeDescription(indent: indent + 2)
        }
        
        if !children.isEmpty {
            result += "\(prefix)  Children (\(children.count)):\n"
            for child in children {
                result += child.treeDescription(indent: indent + 2)
            }
        }
        
        return result
    }
    
    /// Detailed tree content for deep traversal
    internal func detailedContent(depth: Int, parentBranches: [Bool]) -> String {
        var result = ""
        var allItems: [(name: String, hasChildren: Bool)] = []
        
        // Collect all child items
        for prop in properties {
            allItems.append((name: "\(prop.name): \(prop.value)", hasChildren: false))
        }
        
        for handler in handlers {
            allItems.append((name: "\(handler.name): \(handler.value)", hasChildren: false))
        }
        
        if canvasBefore != nil {
            allItems.append((name: "canvas.before", hasChildren: true))
        }
        
        if canvas != nil {
            allItems.append((name: "canvas", hasChildren: true))
        }
        
        if canvasAfter != nil {
            allItems.append((name: "canvas.after", hasChildren: true))
        }
        
        for child in children {
            allItems.append((name: child.name, hasChildren: !child.children.isEmpty || !child.properties.isEmpty))
        }
        
        // Format with tree characters
        var childIndex = 0
        for prop in properties {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)\(prop.name): \(prop.value)\n"
            childIndex += 1
        }
        
        for handler in handlers {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)\(handler.name): \(handler.value)\n"
            childIndex += 1
        }
        
        if let canvasBefore = canvasBefore {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)canvas.before\n"
            result += canvasBefore.detailedContent(depth: depth + 1, parentBranches: parentBranches + [!isLast])
            childIndex += 1
        }
        
        if let canvas = canvas {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)canvas\n"
            result += canvas.detailedContent(depth: depth + 1, parentBranches: parentBranches + [!isLast])
            childIndex += 1
        }
        
        if let canvasAfter = canvasAfter {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)canvas.after\n"
            result += canvasAfter.detailedContent(depth: depth + 1, parentBranches: parentBranches + [!isLast])
            childIndex += 1
        }
        
        for child in children {
            let isLast = childIndex == allItems.count - 1
            let prefix = TreeFormatter.prefix(depth: depth, isLast: isLast, parentBranches: parentBranches)
            result += "\(prefix)\(child.name)\n"
            result += child.detailedContent(depth: depth + 1, parentBranches: parentBranches + [!isLast])
            childIndex += 1
        }
        
        return result
    }
}

/// Template definition (deprecated but still supported)
///
/// Templates create dynamic classes that can be instantiated like regular widgets.
/// Syntax: [TemplateName@BaseClass] or [TemplateName@Base1+Base2]
///
/// Reference: parser.py lines 434-452 (_build_template method)
public struct KvTemplate: KvNode, Sendable {
    /// Name of the template
    public let name: String
    
    /// Base classes to inherit from
    public let baseClasses: [String]
    
    /// Rule defining the template's structure
    public let rule: KvRule
    
    // Position tracking
    public let line: Int
    public let column: Int
    public let endLine: Int?
    public let endColumn: Int?
    
    public init(
        name: String,
        baseClasses: [String],
        rule: KvRule,
        line: Int,
        column: Int = 0,
        endLine: Int? = nil,
        endColumn: Int? = nil
    ) {
        self.name = name
        self.baseClasses = baseClasses
        self.rule = rule
        self.line = line
        self.column = column
        self.endLine = endLine
        self.endColumn = endColumn
    }
}

extension KvTemplate: TreeDisplayable {
    public func treeDescription(indent: Int = 0) -> String {
        let prefix = String(repeating: "  ", count: indent)
        let bases = baseClasses.joined(separator: "+")
        var result = "\(prefix)[\(name)@\(bases)] [line \(line)]:\n"
        result += rule.treeDescription(indent: indent + 1)
        return result
    }
}
