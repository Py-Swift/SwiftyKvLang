/// KV language parser
///
/// Implements recursive descent parsing following parser.py's parse_level() algorithm.
/// Handles indentation-based structure (YAML-inspired), widget selectors, properties,
/// canvas instructions, and directives.
///
/// Reference: parser.py lines 454-777
public final class KvParser {
    private let tokens: [Token]
    private var current: Int = 0
    private var filename: String?
    
    public init(tokens: [Token], filename: String? = nil) {
        self.tokens = tokens
        self.filename = filename
    }
    
    /// Parse tokens into a KV module
    public func parse() throws -> KvModule {
        var directives: [KvDirective] = []
        var rules: [KvRule] = []
        var templates: [KvTemplate] = []
        var root: KvWidget? = nil
        var dynamicClasses: [String: String] = [:]
        
        // First pass: extract directives
        directives = try parseDirectives()
        
        // Second pass: parse rules, templates, and root widget
        while !isAtEnd {
            skipNewlines()
            if isAtEnd { break }
            
            let token = peek()
            
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
            // Otherwise it's a root widget (if we don't have one yet)
            else if case .identifier(_) = token.type {
                if root == nil {
                    root = try parseWidget(level: 0)
                } else {
                    throw KvParserError.syntaxError(
                        line: token.line,
                        message: "Only one root widget allowed in KV file"
                    )
                }
            }
            else {
                // Skip unexpected tokens
                advance()
            }
        }
        
        return KvModule(
            directives: directives,
            rules: rules,
            templates: templates,
            root: root,
            dynamicClasses: dynamicClasses,
            line: 1,
            column: 0
        )
    }
    
    // MARK: - Directive Parsing
    
    /// Parse all directives from token stream
    /// Reference: parser.py lines 490-570
    private func parseDirectives() throws -> [KvDirective] {
        var directives: [KvDirective] = []
        
        for token in tokens {
            guard case .directive(let text) = token.type else { continue }
            
            // Remove #: prefix
            let content = text.dropFirst(2).trimmingCharacters(in: .whitespaces)
            let parts = content.split(separator: " ", maxSplits: 2).map(String.init)
            
            guard let command = parts.first else { continue }
            
            switch command {
            case "kivy":
                // #:kivy 1.0
                if parts.count >= 2 {
                    directives.append(.kivy(version: parts[1], line: token.line))
                }
                
            case "import":
                // #:import alias module.path
                if parts.count >= 3 {
                    directives.append(.import(
                        alias: parts[1],
                        package: parts[2],
                        line: token.line
                    ))
                }
                
            case "set":
                // #:set name value
                if parts.count >= 3 {
                    directives.append(.set(
                        name: parts[1],
                        value: parts[2],
                        line: token.line
                    ))
                }
                
            case "include":
                // #:include [force] path
                var force = false
                var path = ""
                
                if parts.count >= 3 && parts[1] == "force" {
                    force = true
                    path = parts[2]
                } else if parts.count >= 2 {
                    path = parts[1]
                }
                
                // Remove quotes if present
                if path.hasPrefix("'") && path.hasSuffix("'") ||
                   path.hasPrefix("\"") && path.hasSuffix("\"") {
                    path = String(path.dropFirst().dropLast())
                }
                
                directives.append(.include(path: path, force: force, line: token.line))
                
            default:
                throw KvParserError.syntaxError(
                    line: token.line,
                    message: "Unknown directive: #:\(command)"
                )
            }
        }
        
        return directives
    }
    
    // MARK: - Rule Parsing
    
    /// Parse a rule: <Selector>:
    /// Reference: parser.py lines 394-432
    private func parseRule() throws -> KvRule {
        let startToken = peek()
        guard case .leftAngle = startToken.type else {
            throw KvParserError.unexpectedToken(token: startToken, expected: "<")
        }
        advance() // consume <
        
        // Check for avoidance prefix (-)
        var avoidPrevious = false
        if case .minus = peek().type {
            avoidPrevious = true
            advance()
        }
        
        // Parse selector
        let selector = try parseSelector()
        
        // Expect >
        guard case .rightAngle = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: ">")
        }
        advance()
        
        // Expect :
        guard case .colon = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: ":")
        }
        advance()
        
        skipNewlines()
        
        // Expect INDENT for rule body
        guard case .indent = peek().type else {
            // Empty rule is valid
            return KvRule(
                selector: selector,
                avoidPrevious: avoidPrevious,
                line: startToken.line
            )
        }
        advance()
        
        // Parse rule body (properties, canvas, children)
        let (properties, handlers, canvas, canvasBefore, canvasAfter, children) = try parseRuleBody()
        
        // Expect DEDENT
        if case .dedent = peek().type {
            advance()
        }
        
        return KvRule(
            selector: selector,
            properties: properties,
            children: children,
            canvasBefore: canvasBefore,
            canvas: canvas,
            canvasAfter: canvasAfter,
            handlers: handlers,
            avoidPrevious: avoidPrevious,
            line: startToken.line
        )
    }
    
    /// Parse selector inside < >
    /// Can be: WidgetName, .className, Widget1,Widget2, or New@Base+Base2
    /// Also handles avoidance prefix: <-Widget1,-Widget2>
    private func parseSelector() throws -> KvSelector {
        var selectors: [KvSelector] = []
        
        while true {
            // Check for avoidance prefix before each selector
            var hasLocalMinus = false
            if case .minus = peek().type {
                hasLocalMinus = true
                advance()
            }
            
            // Check for class selector (.className)
            if case .dot = peek().type {
                advance()
                guard case .identifier(let className) = peek().type else {
                    throw KvParserError.unexpectedToken(token: peek(), expected: "class name")
                }
                advance()
                selectors.append(.className(className))
            }
            // Check for regular name or dynamic class (Name@Base)
            else if case .identifier(let name) = peek().type {
                advance()
                
                // Check for @ (dynamic class)
                if case .at = peek().type {
                    advance()
                    
                    // Parse base classes (Base1+Base2+...)
                    var bases: [String] = []
                    while case .identifier(let base) = peek().type {
                        advance()
                        bases.append(base)
                        
                        if case .plus = peek().type {
                            advance()
                        } else {
                            break
                        }
                    }
                    
                    selectors.append(.dynamicClass(name: name, bases: bases))
                } else {
                    selectors.append(.name(name))
                }
            }
            else {
                break
            }
            
            // Check for comma (multiple selectors)
            if case .comma = peek().type {
                advance()
            } else {
                break
            }
        }
        
        if selectors.isEmpty {
            throw KvParserError.syntaxError(
                line: peek().line,
                message: "Empty selector"
            )
        }
        
        return selectors.count == 1 ? selectors[0] : .multiple(selectors)
    }
    
    // MARK: - Template Parsing
    
    /// Parse template: [Name@Base]:
    /// Reference: parser.py lines 434-452
    private func parseTemplate() throws -> KvTemplate {
        let startToken = peek()
        guard case .leftBracket = startToken.type else {
            throw KvParserError.unexpectedToken(token: startToken, expected: "[")
        }
        advance()
        
        // Parse name
        guard case .identifier(let name) = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: "template name")
        }
        advance()
        
        // Expect @
        guard case .at = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: "@")
        }
        advance()
        
        // Parse base classes
        var bases: [String] = []
        while case .identifier(let base) = peek().type {
            advance()
            bases.append(base)
            
            if case .plus = peek().type {
                advance()
            } else {
                break
            }
        }
        
        // Expect ]
        guard case .rightBracket = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: "]")
        }
        advance()
        
        // Expect :
        guard case .colon = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: ":")
        }
        advance()
        
        skipNewlines()
        
        // Parse as a rule with dummy selector
        guard case .indent = peek().type else {
            throw KvParserError.syntaxError(
                line: peek().line,
                message: "Template body must be indented"
            )
        }
        advance()
        
        let (properties, handlers, canvas, canvasBefore, canvasAfter, children) = try parseRuleBody()
        
        if case .dedent = peek().type {
            advance()
        }
        
        let rule = KvRule(
            selector: .name(name),
            properties: properties,
            children: children,
            canvasBefore: canvasBefore,
            canvas: canvas,
            canvasAfter: canvasAfter,
            handlers: handlers,
            line: startToken.line
        )
        
        return KvTemplate(
            name: name,
            baseClasses: bases,
            rule: rule,
            line: startToken.line
        )
    }
    
    // MARK: - Widget Parsing
    
    /// Parse a widget instance
    private func parseWidget(level: Int) throws -> KvWidget {
        let startToken = peek()
        guard case .identifier(let name) = startToken.type else {
            throw KvParserError.unexpectedToken(token: startToken, expected: "widget name")
        }
        advance()
        
        // Expect :
        guard case .colon = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: ":")
        }
        advance()
        
        skipNewlines()
        
        // Check for body
        guard case .indent = peek().type else {
            // Empty widget
            return KvWidget(
                name: name,
                level: level,
                line: startToken.line
            )
        }
        advance()
        
        let (properties, handlers, canvas, canvasBefore, canvasAfter, children) = try parseRuleBody()
        
        if case .dedent = peek().type {
            advance()
        }
        
        // Extract id from properties
        let id = properties.first { $0.name == "id" }?.value
        
        return KvWidget(
            name: name,
            id: id,
            properties: properties.filter { $0.name != "id" },
            children: children,
            canvasBefore: canvasBefore,
            canvas: canvas,
            canvasAfter: canvasAfter,
            handlers: handlers,
            level: level,
            line: startToken.line
        )
    }
    
    /// Parse rule/widget body (properties, canvas, children)
    /// Reference: parser.py lines 640-777
    private func parseRuleBody() throws -> (
        properties: [KvProperty],
        handlers: [KvProperty],
        canvas: KvCanvas?,
        canvasBefore: KvCanvas?,
        canvasAfter: KvCanvas?,
        children: [KvWidget]
    ) {
        var properties: [KvProperty] = []
        var handlers: [KvProperty] = []
        var canvas: KvCanvas? = nil
        var canvasBefore: KvCanvas? = nil
        var canvasAfter: KvCanvas? = nil
        var children: [KvWidget] = []
        
        while !isAtEnd {
            skipNewlines()
            
            let token = peek()
            
            // Check for DEDENT (end of body)
            if case .dedent = token.type {
                break
            }
            
            // Check for canvas keywords
            if case .canvas = token.type {
                advance()
                
                // Check for .before or .after
                var canvasType: String = "canvas"
                if case .dot = peek().type {
                    advance()
                    if case .identifier(let modifier) = peek().type {
                        advance()
                        canvasType = "canvas.\(modifier)"
                    }
                }
                
                // Expect :
                guard case .colon = peek().type else {
                    throw KvParserError.unexpectedToken(token: peek(), expected: ":")
                }
                advance()
                
                skipNewlines()
                
                // Parse canvas instructions
                if case .indent = peek().type {
                    advance()
                    let instructions = try parseCanvasInstructions()
                    if case .dedent = peek().type {
                        advance()
                    }
                    
                    let canvasNode = KvCanvas(
                        instructions: instructions,
                        line: token.line
                    )
                    
                    switch canvasType {
                    case "canvas.before":
                        canvasBefore = canvasNode
                    case "canvas.after":
                        canvasAfter = canvasNode
                    default:
                        canvas = canvasNode
                    }
                }
            }
            // Check for property or child widget
            else if case .identifier(let name) = token.type {
                let nextIdx = current + 1
                if nextIdx < tokens.count, case .colon = tokens[nextIdx].type {
                    // It's a property or child widget
                    let nextNextIdx = nextIdx + 1
                    if nextNextIdx < tokens.count {
                        // Check if it's followed by INDENT (child widget) or value (property)
                        skipTo(nextNextIdx)
                        skipNewlines()
                        
                        if case .indent = peek().type {
                            // It's a child widget
                            current = nextIdx - 1 // Reset to identifier
                            let child = try parseWidget(level: 1) // level is relative
                            children.append(child)
                        } else {
                            // It's a property
                            current = nextIdx - 1 // Reset to identifier
                            let property = try parseProperty()
                            
                            if name.hasPrefix("on_") {
                                handlers.append(property)
                            } else {
                                properties.append(property)
                            }
                        }
                    }
                } else {
                    advance()
                }
            }
            else {
                advance()
            }
        }
        
        return (properties, handlers, canvas, canvasBefore, canvasAfter, children)
    }
    
    // MARK: - Property Parsing
    
    /// Parse a property: name: value
    private func parseProperty() throws -> KvProperty {
        let startToken = peek()
        guard case .identifier(let name) = startToken.type else {
            throw KvParserError.unexpectedToken(token: startToken, expected: "property name")
        }
        advance()
        
        // Expect :
        guard case .colon = peek().type else {
            throw KvParserError.unexpectedToken(token: peek(), expected: ":")
        }
        advance()
        
        // Collect value tokens until newline
        var valueTokens: [Token] = []
        while !isAtEnd {
            let token = peek()
            if case .newline = token.type {
                break
            }
            if case .dedent = token.type {
                break
            }
            valueTokens.append(token)
            advance()
        }
        
        // Reconstruct value string from tokens
        let value = reconstructValue(from: valueTokens)
        
        return KvProperty(
            name: name,
            value: value,
            compiledValue: .expression(value),
            line: startToken.line
        )
    }
    
    /// Reconstruct value string from tokens
    private func reconstructValue(from tokens: [Token]) -> String {
        var result = ""
        for token in tokens {
            switch token.type {
            case .identifier(let s), .string(let s), .number(let s):
                result += s + " "
            case .comma:
                result += ", "
            case .colon:
                result += ": "
            case .dot:
                result += "."
            case .leftParen:
                result += "("
            case .rightParen:
                result += ")"
            case .leftBracket:
                result += "["
            case .rightBracket:
                result += "]"
            case .minus:
                result += "-"
            case .plus:
                result += "+"
            default:
                break
            }
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    // MARK: - Canvas Instruction Parsing
    
    /// Parse canvas instructions
    private func parseCanvasInstructions() throws -> [KvCanvasInstruction] {
        var instructions: [KvCanvasInstruction] = []
        
        while !isAtEnd {
            skipNewlines()
            
            let token = peek()
            
            // Check for DEDENT
            if case .dedent = token.type {
                break
            }
            
            // Parse instruction
            if case .identifier(let instructionType) = token.type {
                advance()
                
                // Expect :
                guard case .colon = peek().type else {
                    throw KvParserError.unexpectedToken(token: peek(), expected: ":")
                }
                advance()
                
                skipNewlines()
                
                // Parse instruction properties
                var properties: [KvProperty] = []
                if case .indent = peek().type {
                    advance()
                    
                    while !isAtEnd {
                        skipNewlines()
                        
                        if case .dedent = peek().type {
                            advance()
                            break
                        }
                        
                        if case .identifier = peek().type {
                            let property = try parseProperty()
                            properties.append(property)
                        } else {
                            advance()
                        }
                    }
                }
                
                instructions.append(KvCanvasInstruction(
                    instructionType: instructionType,
                    properties: properties,
                    line: token.line
                ))
            } else {
                advance()
            }
        }
        
        return instructions
    }
    
    // MARK: - Helper Methods
    
    private func peek() -> Token {
        return current < tokens.count ? tokens[current] : Token(type: .eof, line: 0, column: 0)
    }
    
    @discardableResult
    private func advance() -> Token {
        let token = peek()
        if current < tokens.count {
            current += 1
        }
        return token
    }
    
    private func skipNewlines() {
        while case .newline = peek().type {
            advance()
        }
    }
    
    private func skipTo(_ index: Int) {
        current = min(index, tokens.count)
    }
    
    private var isAtEnd: Bool {
        return current >= tokens.count || peek().type == .eof
    }
}
