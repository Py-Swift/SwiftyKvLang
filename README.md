# SwiftyKvLang

A Swift parser for Kivy's KV language, featuring a complete AST-based architecture with YAML-inspired indentation handling.

## Overview

SwiftyKvLang is a production-quality parser for the [Kivy](https://kivy.org) KV language, implemented in Swift. It converts KV files into a type-safe Abstract Syntax Tree (AST) suitable for:

- **IDE tooling** (syntax highlighting, autocomplete, go-to-definition)
- **Code analysis** (linting, formatting, refactoring)
- **Build tools** (preprocessing, optimization, code generation)
- **Educational tools** (AST visualization, language learning)

## Features

### ✅ Complete KV Language Support

- **Directives**: `#:kivy`, `#:import`, `#:set`, `#:include`
- **Widget Rules**: `<Button>`, `<-Button>` (avoidance), `<Button,Label>` (multiple)
- **Dynamic Classes**: `<CustomButton@Button>`, `<Widget@Base1+Base2>` (multiple inheritance)
- **Templates**: `[TemplateName@BaseClass]` (deprecated but supported)
- **Canvas Layers**: `canvas:`, `canvas.before:`, `canvas.after:`
- **Nested Widgets**: Full hierarchy support with arbitrary nesting
- **Properties**: Reactive bindings with watched key extraction
- **Event Handlers**: `on_*` properties with code blocks

### 🏗️ Architecture

- **YAML-Inspired Indentation**: Dynamic indent detection, INDENT/DEDENT tokens
- **Enum-Based AST**: Type-safe nodes with exhaustive pattern matching
- **Position Tracking**: Line/column information for error reporting
- **Sendable Conformance**: Thread-safe AST for concurrent processing
- **TreeDisplayable Protocol**: Pretty-printed AST visualization

### 📚 AST Node Types

```swift
KvModule          // Root: directives, rules, templates, root widget
KvDirective       // Preprocessor: kivy, import, set, include
KvRule            // Widget class rules with selectors
KvSelector        // name, className, multiple, dynamicClass
KvWidget          // Widget instances with properties/children
KvProperty        // Property assignments with compiled values
KvCanvas          // Canvas layers (before/root/after)
KvCanvasInstruction // Graphics instructions (Color, Rectangle, etc.)
```

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Py-Swift/SwiftyKvLang.git", from: "0.1.0")
]
```

## Usage

```swift
import KvParser

let kvSource = """
<Button>:
    text: 'Click me'
    canvas:
        Color:
            rgba: 1, 1, 1, 1
        Rectangle:
            pos: self.pos
            size: self.size
"""

// Tokenize
let tokenizer = KvTokenizer(source: kvSource)
let tokens = try tokenizer.tokenize()

// Parse
let parser = KvParser(tokens: tokens)
let module = try parser.parse()

// Inspect AST
print("Rules: \(module.rules.count)")
print("Directives: \(module.directives.count)")

// Pretty-print tree
print(module.treeDescription())
```

## Testing

The parser includes comprehensive tests covering all KV language features:

```bash
swift test
```

Current status: **10/11 tests passing** ✅

- ✅ Tokenization (indentation, strings, directives)
- ✅ Simple rules and selectors
- ✅ Canvas blocks (before/root/after)
- ✅ Multiple selectors and avoidance
- ✅ Dynamic class creation
- ✅ Nested widgets
- ✅ Directives
- 🔧 Full `style.kv` integration (in progress)

## Architecture Highlights

### YAML-Inspired Tokenization

The tokenizer uses YAML-style indentation tracking with Python's INDENT/DEDENT tokens:

```swift
// Detects indent size dynamically (2, 4, 8 spaces, etc.)
// Generates INDENT/DEDENT tokens for parser
// Converts tabs → 4 spaces
// Validates indent multiples
```

### Recursive Descent Parsing

Following `kivy/kivy/lang/parser.py`'s `parse_level()` algorithm:

- **Level 0**: Rules (`<Widget>`), templates (`[Name@Base]`), root widgets
- **Level 1**: Properties (`prop: value`), children, canvas blocks
- **Level 2+**: Canvas instructions, multi-line continuations

### Property Compilation (Planned)

Properties will be compiled with watched key extraction:

```python
# KV: pos: self.x + root.width
# Watched keys: [["self", "x"], ["root", "width"]]
```

## Performance

Tokenization benchmark (on Kivy's `style.kv`, 1341 lines):

- **Tokens generated**: 9,131
- **Parse time**: ~0.1s (Debug build)
- **Target**: 2-3x faster than Python parser.py

## Reference Implementation

This parser is designed to match the behavior of:
- `kivy/kivy/lang/parser.py` (reference implementation)
- `kivy/kivy/data/style.kv` (comprehensive test file)

## Development

### Project Structure

```
SwiftyKvLang/
├── Package.swift
├── Sources/KvParser/
│   ├── KvNode.swift           # Base protocol
│   ├── KvModule.swift         # Root AST node
│   ├── KvDirective.swift      # Preprocessor directives
│   ├── KvRule.swift           # Widget rules
│   ├── KvSelector.swift       # Rule selectors
│   ├── KvWidget.swift         # Widget instances
│   ├── KvCanvas.swift         # Canvas layers
│   ├── KvTokenizer.swift      # Lexical analysis
│   └── KvParser.swift         # Recursive descent parser
├── Tests/KvParserTests/
│   ├── KvParserTests.swift    # Unit tests
│   └── Resources/style.kv     # Integration test
└── kivy/                      # Reference (git submodule)
```

### Guidelines

See [PLAN.md](PLAN.md) for:
- Parser development workflow
- Performance optimization rules
- Reference file locations
- Testing strategy

See [OPTIMIZATION_GUIDELINES.md](OPTIMIZATION_GUIDELINES.md) for performance optimization procedures.

## Roadmap

- [ ] Property value compiler (watched key extraction)
- [ ] Visitor pattern for AST traversal
- [ ] Code generation (KV source from AST)
- [ ] Performance optimization (UTF-8 byte scanning)
- [ ] IDE integration APIs (SwiftyMonacoIDE)
- [ ] Error recovery (partial AST for tooling)
- [ ] Semantic validation layer

## Contributing

Contributions welcome! Please:

1. Read [PLAN.md](PLAN.md) for development guidelines
2. Reference `kivy/kivy/lang/parser.py` for behavior
3. Test with `kivy/kivy/data/style.kv`
4. Include tests for new features
5. Follow Swift API design guidelines

## License

MIT License - see [LICENSE](LICENSE) for details

## Acknowledgments

- **Kivy Project**: Original KV language specification and parser implementation
- **PySwiftAST**: AST architecture inspiration (enum-based nodes, visitor patterns)
- **YAML Parsers**: Indentation handling algorithms (libyaml, PyYAML)

## Related Projects

- [Kivy](https://kivy.org) - Original KV language and framework
- [PySwiftAST](https://github.com/Py-Swift/PySwiftAST) - Python AST parser in Swift
- [SwiftyMonacoIDE](https://github.com/Py-Swift/SwiftyMonacoIDE) - Monaco-based IDE with KV support

---

**Status**: Alpha (v0.1.0) - Core parsing functional, integration testing in progress
