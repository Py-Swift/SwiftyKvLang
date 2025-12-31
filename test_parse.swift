import Foundation
import KvParser

let kvContent = """
<TestCanvas@BoxLayout>:
    canvas:
        # This is a comment
        Color:
            rgb: 1, 0, 0
        Rectangle:
            pos: self.pos
            size: self.size
    Label:
        text: "This is a test canvas."
    Label:
        text: "This is a test canvas with a comment."


# <MyWidget>:
#     Label:
#         text: "Hello, World!"
"""

print("Tokenizing...")
let tokenizer = KvTokenizer(source: kvContent)
do {
    let tokens = try tokenizer.tokenize()
    
    print("\nTokens:")
    for (i, token) in tokens.enumerated() {
        print("\(i): \(token)")
    }
    
    print("\n\nParsing...")
    let parser = KvParser(tokens: tokens)
    let module = try parser.parse()
    
    print("✅ Parse successful!")
    print("Rules: \(module.rules.count)")
    print("Root widget: \(module.root?.name ?? "none")")
    
} catch {
    print("❌ Error: \(error)")
}
