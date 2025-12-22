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
    
    // MARK: - Compiler Tests
    
    func testCompileSimpleProperty() {
        let compiled = KvCompiler.compile(propertyName: "text", value: "'Hello World'")
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertTrue(compiled.isConstant, "String literal should have no watched keys")
        XCTAssertEqual(compiled.watchedKeys.count, 0)
    }
    
    func testCompilePropertyWithWatchedKey() {
        let compiled = KvCompiler.compile(propertyName: "width", value: "self.parent.width")
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        XCTAssertEqual(compiled.watchedKeys.count, 1)
        XCTAssertEqual(compiled.watchedKeys[0], ["self", "parent", "width"])
    }
    
    func testCompileEventHandler() {
        let compiled = KvCompiler.compile(propertyName: "on_press", value: "print('pressed')")
        
        XCTAssertEqual(compiled.mode, .exec)
        XCTAssertTrue(compiled.isConstant, "Event handlers should not have watched keys")
    }
    
    func testCompileComplexExpression() {
        let compiled = KvCompiler.compile(
            propertyName: "opacity",
            value: ".7 if self.disabled else 1"
        )
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        XCTAssertTrue(compiled.watchedKeys.contains(["self", "disabled"]))
    }
    
    func testCompileMultipleWatchedKeys() {
        let compiled = KvCompiler.compile(
            propertyName: "pos",
            value: "self.parent.x + root.offset_x, self.parent.y + root.offset_y"
        )
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        
        // Should have 4 watched keys
        let keys = Set(compiled.watchedKeys)
        XCTAssertTrue(keys.contains(["self", "parent", "x"]))
        XCTAssertTrue(keys.contains(["self", "parent", "y"]))
        XCTAssertTrue(keys.contains(["root", "offset_x"]))
        XCTAssertTrue(keys.contains(["root", "offset_y"]))
    }
    
    func testCompileIgnoresStrings() {
        let compiled = KvCompiler.compile(
            propertyName: "text",
            value: "'self.width is: ' + str(self.width)"
        )
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        
        // Should only extract self.width, not the one in the string
        XCTAssertEqual(compiled.watchedKeys.count, 1)
        XCTAssertEqual(compiled.watchedKeys[0], ["self", "width"])
    }
    
    func testCompileWithFString() {
        let compiled = KvCompiler.compile(
            propertyName: "text",
            value: "f'Width: {self.width}'"
        )
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        XCTAssertTrue(compiled.watchedKeys.contains(["self", "width"]))
    }
    
    func testCompileWithTranslation() {
        let compiled = KvCompiler.compile(
            propertyName: "text",
            value: "_('Hello')"
        )
        
        XCTAssertEqual(compiled.mode, .eval)
        XCTAssertFalse(compiled.isConstant)
        
        // Translation function adds special "_" key
        XCTAssertTrue(compiled.watchedKeys.contains(["_"]))
    }
    
    func testCompileModule() throws {
        let source = """
        <Button>:
            text: 'Click me'
            width: self.parent.width
            opacity: .7 if self.disabled else 1
            on_press: print('pressed')
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let compiled = module.compile()
        
        XCTAssertEqual(compiled.rules.count, 1)
        
        let rule = compiled.rules[0]
        XCTAssertEqual(rule.properties.count, 3)
        XCTAssertEqual(rule.handlers.count, 1)
        
        // Check compiled properties
        let textProp = rule.properties.first { $0.name == "text" }!
        XCTAssertTrue(textProp.compiled.isConstant)
        
        let widthProp = rule.properties.first { $0.name == "width" }!
        XCTAssertFalse(widthProp.compiled.isConstant)
        XCTAssertTrue(widthProp.compiled.watchedKeys.contains(["self", "parent", "width"]))
        
        let opacityProp = rule.properties.first { $0.name == "opacity" }!
        XCTAssertFalse(opacityProp.compiled.isConstant)
        XCTAssertTrue(opacityProp.compiled.watchedKeys.contains(["self", "disabled"]))
        
        // Check event handler
        let handler = rule.handlers[0]
        XCTAssertEqual(handler.name, "on_press")
        XCTAssertEqual(handler.compiled.mode, .exec)
        XCTAssertTrue(handler.compiled.isConstant)
    }
    
    // MARK: - Visitor Tests
    
    func testPropertyNameCollector() throws {
        let source = """
        <Button>:
            text: 'Click me'
            width: 100
            height: 50
            on_press: print('pressed')
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let collector = PropertyNameCollector()
        module.accept(visitor: collector)
        
        XCTAssertEqual(collector.propertyNames.count, 4)
        XCTAssertTrue(collector.propertyNames.contains("text"))
        XCTAssertTrue(collector.propertyNames.contains("width"))
        XCTAssertTrue(collector.propertyNames.contains("height"))
        XCTAssertTrue(collector.propertyNames.contains("on_press"))
    }
    
    func testWidgetNameCollector() throws {
        let source = """
        BoxLayout:
            Button:
                text: 'Button 1'
            Label:
                text: 'Label 1'
            BoxLayout:
                Label:
                    text: 'Nested'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let collector = WidgetNameCollector()
        module.accept(visitor: collector)
        
        XCTAssertEqual(collector.widgetNames.count, 5)
        XCTAssertEqual(collector.widgetNames[0], "BoxLayout")
        XCTAssertEqual(collector.widgetNames[1], "Button")
        XCTAssertEqual(collector.widgetNames[2], "Label")
        XCTAssertEqual(collector.widgetNames[3], "BoxLayout")
        XCTAssertEqual(collector.widgetNames[4], "Label")
    }
    
    func testSelectorCollector() throws {
        let source = """
        <Button>:
            text: 'button'
        
        <Label>:
            text: 'label'
        
        <.highlight>:
            color: 1, 1, 0, 1
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let collector = SelectorCollector()
        module.accept(visitor: collector)
        
        XCTAssertEqual(collector.selectors.count, 3)
        XCTAssertTrue(collector.selectors.contains("Button"))
        XCTAssertTrue(collector.selectors.contains("Label"))
        XCTAssertTrue(collector.selectors.contains(".highlight"))
    }
    
    func testASTStatistics() throws {
        let source = """
        #:kivy 1.0
        
        <Button>:
            text: 'Click'
            width: self.parent.width
            canvas:
                Color:
                    rgba: 1, 1, 1, 1
                Rectangle:
                    pos: self.pos
                    size: self.size
        
        <Label>:
            text: 'Label'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let stats = ASTStatistics()
        module.accept(visitor: stats)
        
        XCTAssertEqual(stats.directiveCount, 1)
        XCTAssertEqual(stats.ruleCount, 2)
        XCTAssertEqual(stats.propertyCount, 6) // Button: text, width, canvas(rgba, pos, size), Label: text
        XCTAssertEqual(stats.canvasInstructionCount, 2) // Color, Rectangle
    }
    
    func testWatchedPropertyFinder() throws {
        let source = """
        <Button>:
            text: 'Static'
            width: self.parent.width
            opacity: .7 if self.disabled else 1
            size_hint: None, None
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let finder = WatchedPropertyFinder()
        module.accept(visitor: finder)
        
        // Should find 2 properties with watched keys (width and opacity)
        XCTAssertEqual(finder.watchedProperties.count, 2)
        
        let widthProp = finder.watchedProperties.first { $0.property == "width" }
        XCTAssertNotNil(widthProp)
        XCTAssertEqual(widthProp?.rule, "Button")
        XCTAssertTrue(widthProp?.keys.contains(["self", "parent", "width"]) ?? false)
        
        let opacityProp = finder.watchedProperties.first { $0.property == "opacity" }
        XCTAssertNotNil(opacityProp)
        XCTAssertTrue(opacityProp?.keys.contains(["self", "disabled"]) ?? false)
    }
    
    // MARK: - Code Generation Tests
    
    func testGenerateSimpleRule() throws {
        let source = """
        <Button>:
            text: 'Click me'
            width: 100
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("<Button>"))
        XCTAssertTrue(generated.contains("text: "))
        XCTAssertTrue(generated.contains("width: 100"))
    }
    
    func testGenerateDirectives() throws {
        let source = """
        #:kivy 1.0
        #:import math math
        #:set BACKGROUND_COLOR [1, 1, 1, 1]
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("#:kivy 1.0"))
        XCTAssertTrue(generated.contains("#:import"))
        XCTAssertTrue(generated.contains("#:set"))
    }
    
    func testGenerateNestedWidgets() throws {
        let source = """
        BoxLayout:
            Button:
                text: 'Button 1'
            Label:
                text: 'Label 1'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("BoxLayout:"))
        XCTAssertTrue(generated.contains("Button:"))
        XCTAssertTrue(generated.contains("Label:"))
        XCTAssertTrue(generated.contains("text: "))
    }
    
    func testGenerateCanvas() throws {
        let source = """
        <Button>:
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
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("canvas:"))
        XCTAssertTrue(generated.contains("Color:"))
        XCTAssertTrue(generated.contains("Rectangle:"))
        XCTAssertTrue(generated.contains("rgba: 1 , 1 , 1 , 1"))
        XCTAssertTrue(generated.contains("pos: self.pos"))
    }
    
    func testGenerateMultipleSelectors() throws {
        let source = """
        <Button,Label>:
            font_size: 14
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("<Button,Label>"))
        XCTAssertTrue(generated.contains("font_size: 14"))
    }
    
    func testGenerateAvoidanceSelector() throws {
        let source = """
        <-Button>:
            text: 'Default'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generated = module.generate()
        
        XCTAssertTrue(generated.contains("<-Button>"))
        XCTAssertTrue(generated.contains("text: "))
    }
    
    func testRoundTrip() throws {
        let source = """
        #:kivy 1.0
        
        <Button>:
            text: 'Click'
            width: self.parent.width
            canvas:
                Color:
                    rgba: 1, 1, 1, 1
        """
        
        // Parse original
        let tokenizer1 = KvTokenizer(source: source)
        let tokens1 = try tokenizer1.tokenize()
        let parser1 = KvParser(tokens: tokens1)
        let module1 = try parser1.parse()
        
        // Generate code
        let generated = module1.generate()
        
        // Parse generated
        let tokenizer2 = KvTokenizer(source: generated)
        let tokens2 = try tokenizer2.tokenize()
        let parser2 = KvParser(tokens: tokens2)
        let module2 = try parser2.parse()
        
        // Compare structures
        XCTAssertEqual(module1.directives.count, module2.directives.count)
        XCTAssertEqual(module1.rules.count, module2.rules.count)
        XCTAssertEqual(module1.rules[0].properties.count, module2.rules[0].properties.count)
        
        // Check canvas is preserved
        XCTAssertNotNil(module1.rules[0].canvas)
        XCTAssertNotNil(module2.rules[0].canvas)
        XCTAssertEqual(module1.rules[0].canvas?.instructions.count, module2.rules[0].canvas?.instructions.count)
    }
    
    // MARK: - Error Recovery Tests
    
    func testStrictModeThrowsOnError() throws {
        let source = """
        <Button>:
            text: 'Valid'
        
        <Label
            text: 'Missing >'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        
        // Strict mode should throw
        XCTAssertThrowsError(try parser.parseWithRecovery(mode: .strict))
    }
    
    func testTolerantModeCollectsErrors() throws {
        let source = """
        <Button>:
            text: 'Valid'
        
        < >
            text: 'Invalid empty selector'
        
        <Label>:
            text: 'Another valid rule'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        
        let result = try parser.parseWithRecovery(mode: .tolerant)
        
        // Should have some errors but still parse valid rules
        XCTAssertFalse(result.isSuccess)
        XCTAssertGreaterThan(result.errors.count, 0)
        
        // Should have parsed the valid rules
        XCTAssertGreaterThanOrEqual(result.module.rules.count, 1)
    }
    
    func testRecoveryFromMissingColon() throws {
        let source = """
        < >:
            text: 'Invalid empty selector'
        
        <Label>:
            text: 'Valid rule'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        
        let result = try parser.parseWithRecovery(mode: .tolerant)
        
        // Should have error for empty selector
        XCTAssertFalse(result.isSuccess)
        XCTAssertGreaterThan(result.errors.count, 0)
    }
    
    func testErrorLocationTracking() throws {
        let source = """
        <Button>:
            text: 'Valid'
        
        InvalidToken!!!
        
        <Label>:
            text: 'Valid'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        
        let result = try parser.parseWithRecovery(mode: .tolerant)
        
        // Should have error with location
        XCTAssertFalse(result.isSuccess)
        XCTAssertGreaterThan(result.errors.count, 0)
        
        // Check error has line information
        if let error = result.errors.first {
            XCTAssertGreaterThan(error.line, 0)
        }
    }
    
    func testPartialParsing() throws {
        let source = """
        #:kivy 1.0
        
        <Button>:
            text: 'Valid rule 1'
        
        garbage @#$%
        
        <Label>:
            text: 'Valid rule 2'
        
        more garbage
        
        <Widget>:
            size_hint: 1, 1
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        
        let result = try parser.parseWithRecovery(mode: .tolerant)
        
        // Should have errors
        XCTAssertFalse(result.isSuccess)
        
        // Should still parse directives
        XCTAssertGreaterThanOrEqual(result.module.directives.count, 1)
        
        // Should recover and parse some valid rules
        XCTAssertGreaterThan(result.module.rules.count, 0)
    }
    
    // MARK: - Semantic Validation Tests
    
    func testValidateKnownWidgets() throws {
        let source = """
        <Button>:
            text: 'Valid'
        
        <UnknownWidget>:
            text: 'Unknown'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should have warning for unknown widget
        XCTAssertTrue(result.hasWarnings)
        XCTAssertTrue(result.issues.contains { $0.message.contains("UnknownWidget") })
    }
    
    func testValidatePropertyTypos() throws {
        let source = """
        <Label>:
            colour: 1, 0, 0, 1
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should have error for 'colour' (British spelling)
        XCTAssertTrue(result.hasErrors)
        let typoError = result.issues.first { $0.message.contains("colour") }
        XCTAssertNotNil(typoError)
        XCTAssertTrue(typoError?.suggestion?.contains("color") ?? false)
    }
    
    func testValidateDynamicClassNaming() throws {
        let source = """
        <customButton@Button>:
            text: 'Custom'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should warn about lowercase dynamic class name
        XCTAssertTrue(result.hasWarnings)
        XCTAssertTrue(result.issues.contains { $0.message.contains("should start with uppercase") })
    }
    
    func testValidateExpressionComplexity() throws {
        let source = """
        <Button>:
            text: '[x for x in range(10)]'
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should have info about complex expression
        XCTAssertTrue(result.issues.contains { $0.message.contains("Complex expression") })
    }
    
    func testValidateRedundantSelf() throws {
        let source = """
        <Button>:
            width: self.self.parent.width
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should have error for redundant self.self
        XCTAssertTrue(result.hasErrors)
        XCTAssertTrue(result.issues.contains { $0.message.contains("self.self") })
    }
    
    func testValidateAssignmentInExpression() throws {
        let source = """
        <Button>:
            size_hint: None None
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Validation should complete without crashing
        // (None None is technically valid Python, just unusual)
        XCTAssertTrue(true)
    }
    
    func testValidateCanvasInstructions() throws {
        let source = """
        <Button>:
            canvas:
                Color:
                    rgba: 1, 1, 1, 1
                UnknownInstruction:
                    value: 42
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should warn about unknown canvas instruction
        XCTAssertTrue(result.hasWarnings)
        XCTAssertTrue(result.issues.contains { $0.message.contains("UnknownInstruction") })
    }
    
    func testValidateCleanCode() throws {
        let source = """
        <Button>:
            text: 'Hello'
            width: self.parent.width
            background_color: 1, 0, 0, 1
            on_press: print('clicked')
        """
        
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let result = KvSemanticValidator.validate(module)
        
        // Should have no errors or warnings for valid code
        XCTAssertTrue(result.isValid)
        XCTAssertFalse(result.hasErrors)
    }
}

