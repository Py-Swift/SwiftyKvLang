/// Preprocessor directive in KV language
///
/// KV directives start with #: and control parsing behavior:
/// - kivy: Version requirement (e.g., #:kivy 1.0)
/// - import: Import Python modules (e.g., #:import math math)
/// - set: Define global constants (e.g., #:set MY_COLOR (1, 0, 0, 1))
/// - include: Include other .kv files (e.g., #:include other.kv)
///
/// Reference: parser.py lines 490-570 (execute_directives method)
public enum KvDirective: Sendable {
    /// Version requirement: #:kivy 1.0
    case kivy(version: String, line: Int)
    
    /// Import Python module: #:import alias module.path
    case `import`(alias: String, package: String, line: Int)
    
    /// Set global constant: #:set name value
    case set(name: String, value: String, line: Int)
    
    /// Include another KV file: #:include [force] path
    case include(path: String, force: Bool, line: Int)
    
    public var line: Int {
        switch self {
        case .kivy(_, let line),
             .import(_, _, let line),
             .set(_, _, let line),
             .include(_, _, let line):
            return line
        }
    }
}

extension KvDirective: KvNode {
    public var column: Int { 0 }  // Directives always start at column 0
    public var endLine: Int? { line }
    public var endColumn: Int? { nil }
}

extension KvDirective: TreeDisplayable {
    public func treeDescription(indent: Int = 0) -> String {
        let prefix = String(repeating: "  ", count: indent)
        switch self {
        case .kivy(let version, let line):
            return "\(prefix)#:kivy \(version) [line \(line)]\n"
        case .import(let alias, let package, let line):
            return "\(prefix)#:import \(alias) \(package) [line \(line)]\n"
        case .set(let name, let value, let line):
            return "\(prefix)#:set \(name) = \(value) [line \(line)]\n"
        case .include(let path, let force, let line):
            let forceStr = force ? " force" : ""
            return "\(prefix)#:include\(forceStr) \(path) [line \(line)]\n"
        }
    }
}
