import PySwiftAST

/// Helper for parsing Python code in KV event handlers
///
/// Event handlers (properties starting with "on_") contain Python code that gets
/// executed when the event fires. This helper integrates PySwiftAST to parse
/// the Python code into an AST for validation, analysis, and potential transpilation.
///
/// Example handler:
/// ```
/// on_press: print("Button clicked"); self.text = "Clicked"
/// ```
public struct KvPythonParser {
    
    /// Parse Python code from an event handler value
    /// 
    /// Since PySwiftAST's parsePython() returns a Module, we extract the body statements.
    ///
    /// - Parameter code: Python code string from handler value
    /// - Returns: Array of Python statements if parsing succeeds, nil otherwise
    public static func parseHandler(_ code: String) -> [Statement]? {
        // PySwiftAST parses from module level, so we parse and extract body
        guard let module = try? parsePython(code) else {
            return nil
        }
        
        // Extract statements from module body
        switch module {
        case .module(let body):
            return body
        case .interactive(let body):
            return body
        case .expression(let expr):
            // Single expression - wrap in Expr statement
            return [.expr(Expr(value: expr, lineno: 1, colOffset: 0, endLineno: nil, endColOffset: nil))]
        default:
            return nil
        }
    }
    
    /// Check if a property name indicates it contains Python code
    /// - Parameter name: Property name (e.g., "on_press", "on_release")
    /// - Returns: True if this is an event handler with Python code
    public static func isHandler(_ name: String) -> Bool {
        return name.hasPrefix("on_")
    }
    
    /// Parse and validate handler code, returning any syntax errors
    /// - Parameter code: Python code string
    /// - Returns: Array of error messages (empty if valid)
    public static func validateHandler(_ code: String) -> [String] {
        guard let _ = parseHandler(code) else {
            return ["Invalid Python syntax in handler"]
        }
        return []
    }
}
