import Foundation

/// Token types for KV language lexical analysis
///
/// Inspired by YAML tokenization but adapted for KV's Python-expression values
/// and widget-specific syntax (angle brackets, canvas keywords, etc.)
public enum TokenType: Equatable, Sendable {
    // Structure tokens (YAML-inspired)
    case indent
    case dedent
    case newline
    
    // Delimiters
    case colon           // : (key-value separator, YAML-style)
    case comma           // , (list separator)
    case leftAngle       // < (rule selector start)
    case rightAngle      // > (rule selector end)
    case leftBracket     // [ (template start)
    case rightBracket    // ] (template end)
    case leftParen       // (
    case rightParen      // )
    case dot             // . (dotted names)
    case minus           // - (avoidance prefix)
    case at              // @ (dynamic class separator)
    case plus            // + (multiple inheritance)
    
    // Literals
    case identifier(String)
    case string(String)
    case number(String)
    
    // Special keywords
    case canvas          // canvas, canvas.before, canvas.after
    case canvasBefore    // canvas.before
    case canvasAfter     // canvas.after
    
    // Directives (preprocessor commands)
    case directive(String)  // #:kivy, #:import, etc.
    
    // Comments
    case comment(String)    // # comment (YAML-style, not part of AST)
    
    // End of file
    case eof
}

/// Token with position information
public struct Token: Sendable {
    public let type: TokenType
    public let line: Int
    public let column: Int
    public let length: Int
    
    public init(type: TokenType, line: Int, column: Int, length: Int = 1) {
        self.type = type
        self.line = line
        self.column = column
        self.length = length
    }
}

/// KV language tokenizer
///
/// Converts source text into tokens, handling:
/// - YAML-style indentation (INDENT/DEDENT tokens)
/// - Python-style string literals
/// - KV-specific syntax (selectors, directives)
/// - Dynamic indent size detection (first indent determines spacing)
///
/// Design inspired by YAML parsers (libyaml, PyYAML) and Python tokenizer
/// Reference: parser.py lines 572-777 (parse method and parse_level)
public final class KvTokenizer: Sendable {
    private let source: String
    private let lines: [String]
    private var currentLine: Int = 0
    private var currentColumn: Int = 0
    private var indentStack: [Int] = [0]  // YAML-inspired indent tracking
    private var indentSize: Int? = nil     // Detected on first indent
    
    public init(source: String) {
        self.source = source
        // Split into lines, preserving structure for indentation analysis
        self.lines = source.split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
    }
    
    /// Tokenize the source into a list of tokens
    public func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        
        while currentLine < lines.count {
            let line = lines[currentLine]
            
            // Skip empty lines (YAML-style: empty lines are not significant)
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                currentLine += 1
                continue
            }
            
            // Check for directive (starts with #:)
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("#:") {
                let directiveText = line.trimmingCharacters(in: .whitespaces)
                tokens.append(Token(
                    type: .directive(directiveText),
                    line: currentLine + 1,
                    column: 0,
                    length: directiveText.count
                ))
                currentLine += 1
                continue
            }
            
            // Check for comment (starts with # but not #:)
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
                currentLine += 1
                continue
            }
            
            // Process indentation (YAML-inspired algorithm)
            let indentLevel = measureIndent(line)
            try handleIndentation(indentLevel, tokens: &tokens)
            
            // Tokenize the line content
            currentColumn = indentLevel
            try tokenizeLine(line, startColumn: indentLevel, tokens: &tokens)
            
            tokens.append(Token(type: .newline, line: currentLine + 1, column: line.count))
            currentLine += 1
        }
        
        // Emit remaining DEDENT tokens
        while indentStack.count > 1 {
            indentStack.removeLast()
            tokens.append(Token(type: .dedent, line: currentLine + 1, column: 0))
        }
        
        tokens.append(Token(type: .eof, line: currentLine + 1, column: 0))
        return tokens
    }
    
    /// Measure indentation level of a line
    /// Converts tabs to 4 spaces (matching parser.py line 644-646)
    private func measureIndent(_ line: String) -> Int {
        var indent = 0
        for char in line {
            if char == " " {
                indent += 1
            } else if char == "\t" {
                // Tabs count as 4 spaces (parser.py behavior)
                indent += 4
            } else {
                break
            }
        }
        return indent
    }
    
    /// Handle indentation changes, emitting INDENT/DEDENT tokens
    /// Algorithm inspired by YAML indentation tracking and Python's INDENT/DEDENT
    /// Reference: parser.py lines 640-665
    private func handleIndentation(_ level: Int, tokens: inout [Token]) throws {
        let currentIndent = indentStack.last ?? 0
        
        if level > currentIndent {
            // Detect indent size on first indent (YAML-style)
            if indentSize == nil {
                indentSize = level
            }
            
            // Validate indent is a multiple of indent size
            if let size = indentSize, level % size != 0 {
                throw KvParserError.invalidIndentation(
                    line: currentLine + 1,
                    message: "Invalid indentation: expected multiple of \(size) spaces, got \(level)"
                )
            }
            
            indentStack.append(level)
            tokens.append(Token(type: .indent, line: currentLine + 1, column: 0))
        } else if level < currentIndent {
            // Pop indent stack until we reach matching level
            while let top = indentStack.last, top > level {
                indentStack.removeLast()
                tokens.append(Token(type: .dedent, line: currentLine + 1, column: 0))
            }
            
            // Verify we landed on a valid indent level
            if indentStack.last != level {
                throw KvParserError.invalidIndentation(
                    line: currentLine + 1,
                    message: "Dedent doesn't match any previous indentation level"
                )
            }
        }
    }
    
    /// Tokenize content of a single line
    private func tokenizeLine(_ line: String, startColumn: Int, tokens: inout [Token]) throws {
        let content = line.dropFirst(startColumn)
        var index = content.startIndex
        
        while index < content.endIndex {
            let char = content[index]
            let col = startColumn + content.distance(from: content.startIndex, to: index)
            
            // Skip whitespace
            if char.isWhitespace {
                index = content.index(after: index)
                continue
            }
            
            // Single-character tokens
            switch char {
            case ":":
                tokens.append(Token(type: .colon, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case ",":
                tokens.append(Token(type: .comma, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "<":
                tokens.append(Token(type: .leftAngle, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case ">":
                tokens.append(Token(type: .rightAngle, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "[":
                tokens.append(Token(type: .leftBracket, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "]":
                tokens.append(Token(type: .rightBracket, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "-":
                tokens.append(Token(type: .minus, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "@":
                tokens.append(Token(type: .at, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "+":
                tokens.append(Token(type: .plus, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case ".":
                tokens.append(Token(type: .dot, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case "(":
                tokens.append(Token(type: .leftParen, line: currentLine + 1, column: col))
                index = content.index(after: index)
            case ")":
                tokens.append(Token(type: .rightParen, line: currentLine + 1, column: col))
                index = content.index(after: index)
                
            case "'", "\"":
                // String literal (Python-style, including triple quotes)
                let (string, newIndex) = try parseString(content, from: index)
                tokens.append(Token(
                    type: .string(string),
                    line: currentLine + 1,
                    column: col,
                    length: string.count
                ))
                index = newIndex
                
            default:
                // Identifier or number
                if char.isLetter || char == "_" {
                    let (identifier, newIndex) = parseIdentifier(content, from: index)
                    
                    // Check for special keywords
                    let tokenType: TokenType
                    if identifier == "canvas" {
                        tokenType = .canvas
                    } else {
                        tokenType = .identifier(identifier)
                    }
                    
                    tokens.append(Token(
                        type: tokenType,
                        line: currentLine + 1,
                        column: col,
                        length: identifier.count
                    ))
                    index = newIndex
                } else if char.isNumber {
                    let (number, newIndex) = parseNumber(content, from: index)
                    tokens.append(Token(
                        type: .number(number),
                        line: currentLine + 1,
                        column: col,
                        length: number.count
                    ))
                    index = newIndex
                } else {
                    // Unknown character - skip it
                    index = content.index(after: index)
                }
            }
        }
    }
    
    /// Parse string literal (Python-style with triple quotes)
    private func parseString(_ content: Substring, from start: String.Index) throws -> (String, String.Index) {
        let quote = content[start]
        var index = content.index(after: start)
        
        // Check for triple quotes
        var isTriple = false
        if index < content.endIndex, content[index] == quote {
            let nextIndex = content.index(after: index)
            if nextIndex < content.endIndex, content[nextIndex] == quote {
                isTriple = true
                index = content.index(after: nextIndex)
            }
        }
        
        var result = ""
        while index < content.endIndex {
            let char = content[index]
            
            if char == quote {
                if isTriple {
                    // Check for closing triple quote
                    let next1 = content.index(after: index)
                    let next2 = next1 < content.endIndex ? content.index(after: next1) : content.endIndex
                    if next1 < content.endIndex && content[next1] == quote &&
                       next2 < content.endIndex && content[next2] == quote {
                        return (result, content.index(after: next2))
                    }
                    result.append(char)
                } else {
                    return (result, content.index(after: index))
                }
            } else if char == "\\" {
                // Escape sequence
                let nextIndex = content.index(after: index)
                if nextIndex < content.endIndex {
                    result.append(content[nextIndex])
                    index = nextIndex
                }
            } else {
                result.append(char)
            }
            
            index = content.index(after: index)
        }
        
        throw KvParserError.unterminatedString(line: currentLine + 1)
    }
    
    /// Parse identifier
    private func parseIdentifier(_ content: Substring, from start: String.Index) -> (String, String.Index) {
        var index = start
        var result = ""
        
        while index < content.endIndex {
            let char = content[index]
            if char.isLetter || char.isNumber || char == "_" {
                result.append(char)
                index = content.index(after: index)
            } else {
                break
            }
        }
        
        return (result, index)
    }
    
    /// Parse number
    private func parseNumber(_ content: Substring, from start: String.Index) -> (String, String.Index) {
        var index = start
        var result = ""
        
        while index < content.endIndex {
            let char = content[index]
            if char.isNumber || char == "." {
                result.append(char)
                index = content.index(after: index)
            } else {
                break
            }
        }
        
        return (result, index)
    }
}

/// Parser errors
public enum KvParserError: Error, CustomStringConvertible {
    case invalidIndentation(line: Int, message: String)
    case unterminatedString(line: Int)
    case unexpectedToken(token: Token, expected: String)
    case syntaxError(line: Int, message: String)
    
    public var description: String {
        switch self {
        case .invalidIndentation(let line, let message):
            return "Line \(line): \(message)"
        case .unterminatedString(let line):
            return "Line \(line): Unterminated string literal"
        case .unexpectedToken(let token, let expected):
            return "Line \(token.line): Unexpected token, expected \(expected)"
        case .syntaxError(let line, let message):
            return "Line \(line): \(message)"
        }
    }
}
