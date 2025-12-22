/// Error Recovery Support for IDE Integration
///
/// Provides mechanisms for partial parsing and error recovery to enable
/// IDE features (autocomplete, syntax highlighting) even with syntax errors.

import Foundation

/// Represents a parsing error with location and recovery information
public struct ParsingError: Error, Sendable {
    /// The line where the error occurred (1-indexed)
    public let line: Int
    
    /// The column where the error occurred (1-indexed)
    public let column: Int
    
    /// Human-readable error message
    public let message: String
    
    /// The type of error for categorization
    public let kind: ErrorKind
    
    /// Optional recovery suggestion
    public let recoverySuggestion: String?
    
    public init(line: Int, column: Int, message: String, kind: ErrorKind, recoverySuggestion: String? = nil) {
        self.line = line
        self.column = column
        self.message = message
        self.kind = kind
        self.recoverySuggestion = recoverySuggestion
    }
    
    public enum ErrorKind: String, Sendable {
        case unexpectedToken = "Unexpected Token"
        case missingToken = "Missing Token"
        case invalidIndentation = "Invalid Indentation"
        case unterminatedString = "Unterminated String"
        case invalidSelector = "Invalid Selector"
        case invalidProperty = "Invalid Property"
        case invalidDirective = "Invalid Directive"
        case duplicateRule = "Duplicate Rule"
        case unknown = "Unknown Error"
    }
}

/// Parse result that includes both the AST and any errors encountered
public struct ParseResult: Sendable {
    /// The parsed module (may be partial if errors occurred)
    public let module: KvModule
    
    /// Errors encountered during parsing
    public let errors: [ParsingError]
    
    /// Whether the parse was successful (no errors)
    public var isSuccess: Bool {
        errors.isEmpty
    }
    
    public init(module: KvModule, errors: [ParsingError]) {
        self.module = module
        self.errors = errors
    }
}

/// Parser mode for error handling
public enum ParserMode: Sendable {
    /// Strict mode: throw on first error (default)
    case strict
    
    /// Tolerant mode: collect errors and attempt recovery
    case tolerant
}

extension KvParser {
    /// Parse with error recovery support
    /// In tolerant mode, collects errors and attempts to continue parsing
    public func parseWithRecovery(mode: ParserMode = .strict) throws -> ParseResult {
        var errors: [ParsingError] = []
        
        if mode == .strict {
            // Original behavior: throw on first error
            let module = try parse()
            return ParseResult(module: module, errors: [])
        }
        
        // Tolerant mode: collect errors and attempt recovery
        return parseWithErrorRecovery(errors: &errors)
    }
    
    private func parseWithErrorRecovery(errors: inout [ParsingError]) -> ParseResult {
        var directives: [KvDirective] = []
        var rules: [KvRule] = []
        var templates: [KvTemplate] = []
        var root: KvWidget? = nil
        var dynamicClasses: [String: String] = [:]
        
        directives.reserveCapacity(4)
        rules.reserveCapacity(80)
        templates.reserveCapacity(5)
        
        // Collect directives
        while case .directive(let text) = peek().type {
            let token = peek()
            do {
                let directive = try parseDirective(text: text, line: token.line)
                directives.append(directive)
                advance()
            } catch {
                recordError(error, in: &errors)
                advance() // Skip problematic token
            }
        }
        
        // Parse rules, templates, and root widget with error recovery
        while !isAtEnd {
            skipNewlines()
            if isAtEnd { break }
            
            let token = peek()
            
            do {
                // Check for rule selector: <...>
                if case .leftAngle = token.type {
                    let rule = try parseRule()
                    rules.append(rule)
                    
                    // Collect dynamic class definitions
                    if case .dynamicClass(let name, let bases) = rule.selector {
                        dynamicClasses[name] = bases.joined(separator: "+")
                    }
                }
                // Check for template: [...]
                else if case .leftBracket = token.type {
                    let template = try parseTemplate()
                    templates.append(template)
                }
                // Otherwise it's a root widget
                else if case .identifier(_) = token.type {
                    if root == nil {
                        root = try parseWidget(level: 0)
                    } else {
                        let error = ParsingError(
                            line: token.line,
                            column: token.column,
                            message: "Only one root widget allowed in KV file",
                            kind: .unexpectedToken,
                            recoverySuggestion: "Remove extra root widget or convert to a rule with <WidgetName>:"
                        )
                        errors.append(error)
                        // Skip this widget
                        advance()
                    }
                }
                else {
                    // Unexpected token - skip and record error
                    let error = ParsingError(
                        line: token.line,
                        column: token.column,
                        message: "Unexpected token: \(token.type)",
                        kind: .unexpectedToken,
                        recoverySuggestion: "Expected a rule selector (<...>), template ([...]), or widget name"
                    )
                    errors.append(error)
                    advance()
                }
            } catch {
                // Record error and attempt recovery
                recordError(error, in: &errors)
                recoverFromError()
            }
        }
        
        let module = KvModule(
            directives: directives,
            rules: rules,
            templates: templates,
            root: root,
            dynamicClasses: dynamicClasses,
            line: 1,
            column: 0
        )
        
        return ParseResult(module: module, errors: errors)
    }
    
    /// Convert thrown error to ParsingError and append to list
    private func recordError(_ error: Error, in errors: inout [ParsingError]) {
        if let kvError = error as? KvParserError {
            let parsingError = convertKvParserError(kvError)
            errors.append(parsingError)
        } else {
            // Generic error
            let token = peek()
            errors.append(ParsingError(
                line: token.line,
                column: token.column,
                message: "Parse error: \(error.localizedDescription)",
                kind: .unknown
            ))
        }
    }
    
    /// Convert KvParserError to ParsingError
    private func convertKvParserError(_ error: KvParserError) -> ParsingError {
        switch error {
        case .unexpectedToken(let token, let expected):
            return ParsingError(
                line: token.line,
                column: token.column,
                message: "Expected \(expected), got \(token.type)",
                kind: .unexpectedToken,
                recoverySuggestion: "Check syntax near this token"
            )
        case .syntaxError(let line, let message):
            return ParsingError(
                line: line,
                column: 0,
                message: message,
                kind: .unexpectedToken
            )
        case .invalidIndentation(let line, let message):
            return ParsingError(
                line: line,
                column: 0,
                message: message,
                kind: .invalidIndentation,
                recoverySuggestion: "Check indentation levels (use spaces, not tabs)"
            )
        case .unterminatedString(let line):
            return ParsingError(
                line: line,
                column: 0,
                message: "Unterminated string literal",
                kind: .unterminatedString,
                recoverySuggestion: "Add closing quote"
            )
        }
    }
    
    /// Attempt to recover from parse error by advancing to a safe synchronization point
    private func recoverFromError() {
        // Skip tokens until we find a synchronization point:
        // - Next rule selector (<)
        // - Next template ([)
        // - Next widget identifier at level 0
        // - EOF
        
        while !isAtEnd {
            let token = peek()
            
            switch token.type {
            case .leftAngle, .leftBracket:
                // Found potential start of new rule/template
                return
            case .identifier(_):
                // Check if at level 0 (potential root widget)
                if indentLevel() == 0 {
                    return
                }
            case .newline:
                // Skip newlines during recovery
                advance()
                continue
            default:
                break
            }
            
            advance()
        }
    }
    
    /// Get current indentation level from token stream
    private func indentLevel() -> Int {
        // Count INDENT tokens before current position
        var level = 0
        var pos = 0
        
        while pos < current {
            if case .indent = tokens[pos].type {
                level += 1
            } else if case .dedent = tokens[pos].type {
                level -= 1
            }
            pos += 1
        }
        
        return max(0, level)
    }
}
