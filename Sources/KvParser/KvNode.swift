/// Base protocol for all KV language AST nodes.
/// Provides position tracking for error reporting and debugging.
///
/// Design inspired by PySwiftAST's ASTNode protocol and YAML's event-based parsing,
/// adapted for KV language's widget-centric structure.
public protocol KvNode: Sendable {
    /// Line number where this node starts (1-indexed, matching parser.py)
    var line: Int { get }
    
    /// Column offset where this node starts (0-indexed)
    var column: Int { get }
    
    /// Optional end line number (for multi-line nodes)
    var endLine: Int? { get }
    
    /// Optional end column offset
    var endColumn: Int? { get }
}

/// Extension providing default implementations for single-line nodes
extension KvNode {
    public var endLine: Int? { nil }
    public var endColumn: Int? { nil }
}

/// Protocol for nodes that can be displayed as a tree structure
/// (similar to PySwiftAST's TreeDisplayable)
public protocol TreeDisplayable {
    /// Returns a formatted string representation suitable for debugging
    func treeDescription(indent: Int) -> String
}

/// Position information for a node
public struct SourcePosition: Sendable, Equatable {
    public let line: Int
    public let column: Int
    public let endLine: Int?
    public let endColumn: Int?
    
    public init(line: Int, column: Int, endLine: Int? = nil, endColumn: Int? = nil) {
        self.line = line
        self.column = column
        self.endLine = endLine
        self.endColumn = endColumn
    }
}
