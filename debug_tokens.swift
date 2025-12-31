#!/usr/bin/env swift

import Foundation

// Add the Sources directory to the import path
let sourcesPath = "/Volumes/CodeSSD/GitHub/SwiftyKvLang/Sources"

// Read the KV file
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

print("File content:")
print(kvContent)
print("\n" + String(repeating: "=", count: 80))
print("Lines with indentation:")
for (i, line) in kvContent.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
    let spaces = line.prefix(while: { $0 == " " }).count
    print("Line \(i+1) [indent=\(spaces)]: '\(line)'")
}
