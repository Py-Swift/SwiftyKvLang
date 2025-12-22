# Cline Rules for SwiftyKvLang Development

## Parser Development Guidelines

### Always Consult Grammar File
When working on parser-related code (Parser.swift, Tokenizer.swift, or any parsing logic):

1. **ALWAYS reference `kivy/kivy/lang/parser.py`** before making changes
2. **Read the relevant grammar rules** for the feature you're implementing or fixing
3. **Verify your implementation matches the official Python grammar** defined in parser.py
4. **Include psrser rule references** in comments when implementing parser logic

### Grammar File Usage Pattern
```
When fixing/implementing parser feature X:
1. Read parser.py to find the rule for X
2. Understand the parser notation 
3. Implement according to the parser rule
4. Add a comment referencing the parser rule in the code
```



### Code Comment Convention

### Verification Steps
1. ✅ Check parser.py for the official rule
2. ✅ Verify implementation matches grammar
3. ✅ Test with real-world kvlang files
4. ✅ Ensure AST structure matches kvlang's parser module

## Performance Optimization Guidelines

### ALWAYS Follow OPTIMIZATION_GUIDELINES.md

When making ANY performance-related changes, **MUST** follow the workflow in:
`OPTIMIZATION_GUIDELINES.md`

### Critical Rules (Never Skip These!)

1. **Establish Baseline FIRST**
   ```bash
   swift test -c release --filter PerformanceTests 2>&1 | tee baseline.txt
   ```
   - Record current metrics before any changes
   - Update `performance_history.json` with baseline

2. **ONE Optimization at a Time**
   - ✅ Good: "Optimize parseExpression() bounds checking"
   - ❌ Bad: "Optimize parser, tokenizer, and codegen"
   - Each change must be isolated and measurable

3. **Profile Before Optimizing**
   - **Never guess what's slow** - always profile first
   - Use Instruments Time Profiler or sampling
   - Focus on actual hotspots, not assumptions

4. **Test Everything After Changes**
   ```bash
   swift test  # All 81 tests must pass
   swift test -c release --filter PerformanceTests  # Measure impact
   ```
   - **If ANY test fails → REVERT immediately**
   - **If performance regresses >2% → REVERT immediately**

5. **Update Performance History**
   - Add entry to `performance_history.json` after every optimization
   - Include: date, commit, metrics, delta percentages, status
   - Document what worked and what didn't

### Performance Decision Matrix

After measuring performance impact:
- **Improved >2%**: ✅ Keep change, commit, update history
- **Neutral ±2%**: 🤔 Keep only if code is simpler, otherwise revert
- **Regressed >2%**: ❌ **REVERT immediately**, try different approach

### Current Performance Baseline (2025-11-25)
- **Parsing**: 6.5 ms median (1.34x vs Python, target: 2.0x)
- **Round-trip**: 26.3 ms median (1.15x vs Python, target: 1.5x)
- **Tokenization**: 44.2 ms median (51% faster than old baseline)

### Optimization Priority (Based on Profiling)

1. **High Impact**: Tokenization (44ms) - UTF-8 byte array could give 6x improvement
2. **Medium Impact**: Code generation (~5ms) - String building optimization
3. **Low Impact**: Parsing (6.5ms) - Already quite fast

### Quick Reference: Safe vs Unsafe Optimizations

**Safe (Try First)**:
- Better algorithms (O(n²) → O(n))
- Reduce allocations (`reserveCapacity`, reuse buffers)
- Compiler hints (`@inline`, `@_optimize(speed)`)
- Caching repeated work

**Unsafe (Only After Profiling Proves >5% Benefit)**:
- `unsafelyUnwrapped` (when bounds already checked)
- `withUnsafeBufferPointer` (for hot loops)
- `UnsafePointer` (for string scanning)
- **MUST** document why it's safe in code comments

### Commit Message Template for Optimizations

```
perf: [brief description of optimization]

- [Component]: [before]ms -> [after]ms ([X]% improvement)
- Overall speedup: [X.XX]x vs Python (was [X.XX]x)
- All [N] tests passing
- [Specific test] validated

[Brief explanation of what was optimized and why it works]

Profiling showed [finding]. [Approach taken]. [Result achieved].
```

**Rules for SwiftyKvLang**:
- ✅ **READ this file** at the start of each session

**SwiftyMonacoIDE Responsibilities**:
- Adds tasks when it discovers SwiftyKvLang is missing features
- Tasks describe what's needed and why (for IDE functionality)
- Tasks include examples and expected behavior

**Example Task Entry**:
```markdown
## Task: Add getVariableDefinitionLocation() API

**Why**: SwiftyMonacoIDE needs "Go to Definition" for variables

**What**: Add method to TypeChecker:
```swift
public func getVariableDefinitionLocation(_ name: String, at line: Int) -> (file: String, line: Int, column: Int)?
```

**Status**: Not started
```

#### 2. SwiftyMonacoIDE-TODO.md
**Purpose**: Internal tasks for SwiftyMonacoIDE development

**Rules for SwiftyKvLang**:
- ❌ **DO NOT read or modify** this file
- ❌ **DO NOT implement** tasks from this file
- ❌ This file is for SwiftyMonacoIDE's internal coordination only

**SwiftyMonacoIDE Responsibilities**:
- Tracks its own features, bugs, and improvements
- Not relevant to SwiftyKvLang development

### Workflow: Ping-Pong Development

The TODO system enables coordination between packages:

```
SwiftyMonacoIDE discovers issue
    ↓
Adds task to SwiftyKvLang-TODO.md
    ↓
SwiftyKvLang reads SwiftyKvLang-TODO.md
    ↓
SwiftyKvLang implements the feature
    ↓
SwiftyKvLang removes completed task
    ↓
SwiftyMonacoIDE uses new feature
    ↓
Cycle repeats as needed
```

### Best Practices

**When Starting Work on SwiftyKvLang**:
1. Check `/Volumes/CodeSSD/GitHub/SwiftyKvLang/SwiftyMonacoIDE/TODO/SwiftyKvLang-TODO.md`
2. Prioritize tasks that unblock SwiftyMonacoIDE features
3. Implement with tests and documentation
4. Remove task from file when complete
5. Commit with reference to completed task

**Task Completion Checklist**:
- [ ] Feature fully implemented with tests
- [ ] Public API documented
- [ ] All tests passing
- [ ] Task removed from SwiftyKvLang-TODO.md
- [ ] Commit message references the task

**Task Update Format** (if partially complete):
```markdown
## Task: [Name]

**Status**: In Progress (50% - API added, tests pending)
**Branch**: feature/task-name
**Blocker**: Waiting on [dependency]
```

**Separation of Concerns**:
- SwiftyKvLang = Pure parser + type checker + core APIs
- SwiftyMonacoIDE = IDE features + Monaco integration + UI logic
- TODO files = Communication bridge between packages

## File References
- Parser: `kivy/kivy/lang/parser.py`
- Reference KV File: `kivy/kivy/data/style.kv` (1341 lines, comprehensive test case)
- Optimization Guidelines: `/Volumes/CodeSSD/GitHub/SwiftyKvLang/OPTIMIZATION_GUIDELINES.md`
- Performance History: `performance_history.json`
- Profiling Analysis: `PROFILING_ANALYSIS.md`

## Implementation Status (2025-12-22)

### ✅ Completed
- **Package Structure**: Package.swift with KvParser target, test infrastructure
- **AST Node Types**: Complete enum-based hierarchy (KvModule, KvDirective, KvRule, KvSelector, KvWidget, KvProperty, KvCanvas, KvCanvasInstruction)
- **Tokenizer**: YAML-inspired indentation tracking, dynamic indent detection, string literals, directives
  - Successfully tokenizes style.kv (9131 tokens)
  - INDENT/DEDENT generation working correctly
  - Handles tabs→spaces conversion, comment stripping
- **Parser Core**: Recursive descent parser with parse_level() logic
  - ✅ Simple rules: `<Button>: ...`
  - ✅ Canvas blocks: `canvas:`, `canvas.before:`, `canvas.after:`
  - ✅ Multiple selectors: `<Button,Label>:`
  - ✅ Avoidance selector: `<-Button>:`
  - ✅ Dynamic classes: `<CustomButton@Button>:`
  - ✅ Nested widgets and children
  - ✅ Directives: `#:kivy`, `#:import`, `#:set`, `#:include`
  - ✅ Templates: `[Name@Base]:`
- **Test Suite**: 11 tests, 10 passing

### 🔧 In Progress
- **style.kv Integration**: Parser successfully handles first 30 lines, discovering edge cases
  - Issue: Complex property value parsing (multi-line, complex expressions)
  - Need: Better tokenization of property values with parentheses, brackets
- **Property Compiler**: Not yet started - will extract watched keys from expressions

### 📋 Next Steps
1. Debug and fix style.kv parsing beyond line 30
2. Implement property value compiler (watched keys extraction)
3. Add visitor pattern for AST traversal
4. Implement code generation (round-trip testing)
5. Performance baseline measurement

### Key Findings
- **YAML-inspired indentation works well**: INDENT/DEDENT algorithm handles nested structures correctly
- **Tokenization is clean**: 9131 tokens for 1341-line file, good granularity
- **Parser structure is sound**: Basic parsing logic handles most KV features
- **Edge cases to address**:
  - Property values with complex expressions
  - Multi-line property values
  - Better EOF handling in parser
## Workflow Summary

### For Parser Changes:
1. Check `kivy/kivy/lang/parser.py` for official rule
2. Implement with parser rule comment
3. Test with real kv files
4. Verify AST structure correctness

### For Performance Changes:
1. Read `OPTIMIZATION_GUIDELINES.md` completely
2. Establish baseline and record metrics
3. Profile to find actual hotspots
4. Make ONE targeted change
5. Test all tests (must pass)
6. Measure performance (must improve or stay neutral)
7. Update `performance_history.json`
8. Commit with performance metrics

### Never:
- ❌ Skip parser verification for parser changes
- ❌ Skip baseline measurement for optimizations
- ❌ Make multiple optimizations at once
- ❌ Accept test failures or performance regressions
- ❌ Optimize without profiling first
- ❌ Use unsafe operations without proven benefit
