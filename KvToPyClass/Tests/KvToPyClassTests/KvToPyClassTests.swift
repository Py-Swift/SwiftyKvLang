import XCTest
@testable import KvToPyClass
import KvParser

final class KvToPyClassTests: XCTestCase {
    
    func testSimpleButtonGeneration() throws {
        let kvSource = """
        <MyButton@Button>:
            text: 'Click me'
            size_hint: (0.5, 0.5)
        """
        
        let tokenizer = KvTokenizer(source: kvSource)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generator = KvToPyClassGenerator(module: module)
        let pythonCode = try generator.generate()
        
        // Verify the generated code contains expected elements
        XCTAssertTrue(pythonCode.contains("class MyButton"))
        XCTAssertTrue(pythonCode.contains("def __init__"))
        XCTAssertTrue(pythonCode.contains("super().__init__"))
        XCTAssertTrue(pythonCode.contains("self.text"))
        XCTAssertTrue(pythonCode.contains("'Click me'"))
        
        print("Generated Python code:")
        print(pythonCode)
    }
    
    func testButtonWithHandler() throws {
        let kvSource = """
        <MyButton@Button>:
            text: 'Press me'
            on_press: print("Button pressed!")
        """
        
        let tokenizer = KvTokenizer(source: kvSource)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generator = KvToPyClassGenerator(module: module)
        let pythonCode = try generator.generate()
        
        // Verify handler generation
        XCTAssertTrue(pythonCode.contains("class MyButton"))
        XCTAssertTrue(pythonCode.contains("def _on_press_handler"))
        XCTAssertTrue(pythonCode.contains("self.bind"))
        XCTAssertTrue(pythonCode.contains("print"))
        
        print("Generated Python code with handler:")
        print(pythonCode)
    }
    
    func testWidgetWithChildren() throws {
        let kvSource = """
        <MyLayout@BoxLayout>:
            orientation: 'vertical'
            Button:
                text: 'Top'
            Button:
                text: 'Bottom'
        """
        
        let tokenizer = KvTokenizer(source: kvSource)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generator = KvToPyClassGenerator(module: module)
        let pythonCode = try generator.generate()
        
        // Verify child widget generation
        XCTAssertTrue(pythonCode.contains("class MyLayout"))
        XCTAssertTrue(pythonCode.contains("self.add_widget"))
        XCTAssertTrue(pythonCode.contains("Button"))
        
        print("Generated Python code with children:")
        print(pythonCode)
    }
    
    func testMultipleClasses() throws {
        let kvSource = """
        <FirstWidget@Label>:
            text: 'First'
        
        <SecondWidget@Button>:
            text: 'Second'
        """
        
        let tokenizer = KvTokenizer(source: kvSource)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        
        let generator = KvToPyClassGenerator(module: module)
        let pythonCode = try generator.generate()
        
        // Verify multiple classes
        XCTAssertTrue(pythonCode.contains("class FirstWidget"))
        XCTAssertTrue(pythonCode.contains("class SecondWidget"))
        
        print("Generated Python code with multiple classes:")
        print(pythonCode)
    }
}
