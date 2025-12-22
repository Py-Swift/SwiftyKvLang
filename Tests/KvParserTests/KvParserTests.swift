import XCTest
@testable import KvParser

/// Test suite for KV language parser
///
/// Tests the complete parsing pipeline:
/// 1. Tokenization (YAML-inspired indentation handling)
/// 2. Parsing (recursive descent with selectors, properties, canvas)
/// 3. AST validation (structure matches KV language specification)
final class KvParserTests: XCTestCase {
    
    // MARK: - Basic Tokenization Tests
    
    func testTokenizeSimpleRule() throws {
        let source = """
        <Button>:
            text: 'Hello'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        
        // Verify we have expected token types
        XCTAssertTrue(tokens.contains { if case .leftAngle = $0.type { return true }; return false })
        XCTAssertTrue(tokens.contains { if case .identifier("Button") = $0.type { return true }; return false })
        XCTAssertTrue(tokens.contains { if case .rightAngle = $0.type { return true }; return false })
        XCTAssertTrue(tokens.contains { if case .indent = $0.type { return true }; return false })
        XCTAssertTrue(tokens.contains { if case .dedent = $0.type { return true }; return false })
    }
    
    func testIndentationDetection() throws {
        let source = """
        Widget:
            BoxLayout:
                Label:
                    text: 'test'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        
        // Count INDENT/DEDENT tokens
        let indents = tokens.filter { if case .indent = $0.type { return true }; return false }.count
        let dedents = tokens.filter { if case .dedent = $0.type { return true }; return false }.count
        
        XCTAssertEqual(indents, 3, "Should have 3 INDENT tokens for 3 nesting levels")
        XCTAssertEqual(dedents, 3, "Should have 3 DEDENT tokens")
    }
    
    func testDirectiveTokenization() throws {
        let source = """
        #:kivy 1.0
        #:import math math
        
        <Widget>:
            pass
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        
        let directives = tokens.filter { 
            if case .directive = $0.type { return true }
            return false
        }
        
        XCTAssertEqual(directives.count, 2, "Should find 2 directives")
    }
    
    // MARK: - Basic Parsing Tests
    
    func testParseSimpleRule() throws {
        let source = """
        <Button>:
            text: 'Click me'
            size: 100, 50
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.rules.count, 1, "Should have 1 rule")
        
        let rule = module.rules[0]
        XCTAssertEqual(rule.selector.primaryName, "Button")
        XCTAssertEqual(rule.properties.count, 2, "Should have 2 properties")
        XCTAssertEqual(rule.properties[0].name, "text")
        XCTAssertEqual(rule.properties[1].name, "size")
    }
    
    func testParseRuleWithCanvas() throws {
        let source = """
        <Label>:
            canvas:
                Color:
                    rgba: 1, 1, 1, 1
                Rectangle:
                    pos: self.pos
                    size: self.size
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.rules.count, 1)
        
        let rule = module.rules[0]
        XCTAssertNotNil(rule.canvas, "Rule should have canvas")
        XCTAssertEqual(rule.canvas?.instructions.count, 2, "Canvas should have 2 instructions")
        
        let colorInstruction = rule.canvas?.instructions[0]
        XCTAssertEqual(colorInstruction?.instructionType, "Color")
        XCTAssertEqual(colorInstruction?.properties.count, 1)
        
        let rectInstruction = rule.canvas?.instructions[1]
        XCTAssertEqual(rectInstruction?.instructionType, "Rectangle")
        XCTAssertEqual(rectInstruction?.properties.count, 2)
    }
    
    func testParseMultipleSelectors() throws {
        let source = """
        <Button,ToggleButton>:
            background_color: 1, 1, 1, 1
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.rules.count, 1)
        
        let rule = module.rules[0]
        if case .multiple(let selectors) = rule.selector {
            XCTAssertEqual(selectors.count, 2)
        } else {
            XCTFail("Expected multiple selector")
        }
    }
    
    func testParseAvoidanceSelector() throws {
        let source = """
        <-Button>:
            text: 'Override'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.rules.count, 1)
        
        let rule = module.rules[0]
        XCTAssertTrue(rule.avoidPrevious, "Rule should have avoidPrevious flag")
    }
    
    func testParseDynamicClass() throws {
        let source = """
        <CustomButton@Button>:
            text: 'Custom'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.rules.count, 1)
        XCTAssertTrue(module.dynamicClasses.keys.contains("CustomButton"))
        
        let rule = module.rules[0]
        if case .dynamicClass(let name, let bases) = rule.selector {
            XCTAssertEqual(name, "CustomButton")
            XCTAssertEqual(bases, ["Button"])
        } else {
            XCTFail("Expected dynamic class selector")
        }
    }
    
    func testParseNestedWidgets() throws {
        let source = """
        BoxLayout:
            Label:
                text: 'Hello'
            Button:
                text: 'Click'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertNotNil(module.root, "Should have root widget")
        XCTAssertEqual(module.root?.name, "BoxLayout")
        XCTAssertEqual(module.root?.children.count, 2, "Root should have 2 children")
        
        let label = module.root?.children[0]
        XCTAssertEqual(label?.name, "Label")
        XCTAssertEqual(label?.properties.first?.name, "text")
        
        let button = module.root?.children[1]
        XCTAssertEqual(button?.name, "Button")
    }
    
    func testParseDirectives() throws {
        let source = """
        #:kivy 1.0
        #:import math math
        #:set MY_COLOR (1, 0, 0, 1)
        #:include other.kv
        
        <Widget>:
            pass
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        XCTAssertEqual(module.directives.count, 4, "Should have 4 directives")
        
        // Check directive types
        let hasKivy = module.directives.contains { 
            if case .kivy = $0 { return true }
            return false
        }
        let hasImport = module.directives.contains { 
            if case .import = $0 { return true }
            return false
        }
        let hasSet = module.directives.contains { 
            if case .set = $0 { return true }
            return false
        }
        let hasInclude = module.directives.contains { 
            if case .include = $0 { return true }
            return false
        }
        
        XCTAssertTrue(hasKivy)
        XCTAssertTrue(hasImport)
        XCTAssertTrue(hasSet)
        XCTAssertTrue(hasInclude)
    }
    
    // MARK: - Style.kv Integration Test
    
    func testParseStyleKv() throws {
        // Load style.kv from resources
        let bundle = Bundle.module
        var styleUrl = bundle.url(forResource: "style", withExtension: "kv", subdirectory: "Resources")
        
        // Fallback: try without subdirectory
        if styleUrl == nil {
            styleUrl = bundle.url(forResource: "style", withExtension: "kv")
        }
        
        guard let url = styleUrl else {
            // Skip test if resource not found (may happen in some build configurations)
            print("Skipping testParseStyleKv: style.kv not found in bundle")
            return
        }
        
        let source = try String(contentsOf: url, encoding: .utf8)
        
        // Tokenize
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        
        print("Tokenized style.kv: \(tokens.count) tokens")
        
        // Parse
        let parser = KvParser(tokens: tokens, filename: "style.kv")
        let module = try parser.parse()
        
        print("Parsed style.kv:")
        print("  Directives: \(module.directives.count)")
        print("  Rules: \(module.rules.count)")
        print("  Templates: \(module.templates.count)")
        print("  Dynamic classes: \(module.dynamicClasses.count)")
        
        // Validate structure
        XCTAssertGreaterThan(module.rules.count, 0, "style.kv should contain widget rules")
        XCTAssertGreaterThan(module.directives.count, 0, "style.kv should have directives")
        
        // Print first few rules for debugging
        print("\nFirst 5 rules:")
        for (index, rule) in module.rules.prefix(5).enumerated() {
            print("  \(index + 1). \(rule.selector.primaryName) (line \(rule.line))")
            print("     Properties: \(rule.properties.count)")
            print("     Children: \(rule.children.count)")
            print("     Canvas: \(rule.canvas != nil ? "yes" : "no")")
        }
        
        // Print tree structure of first rule
        if let firstRule = module.rules.first {
            print("\nFirst rule tree structure:")
            print(firstRule.treeDescription())
        }
    }
}
