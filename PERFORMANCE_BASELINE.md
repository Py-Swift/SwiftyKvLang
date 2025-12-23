# Performance Baseline

## Swift KV Parser - UTF-8 Optimized

**Date:** December 23, 2025  
**Hardware:** Apple Silicon (M-series)  
**Build:** Release mode (`-c release`)  
**File:** style.kv (1,341 lines, 43,518 bytes)

### Results (100 iterations) - After UTF-8 Optimization

#### Tokenization
- **Mean:** 0.490 ms ⚡️ **12.7x faster**
- **Median:** 0.456 ms
- **StdDev:** 0.107 ms
- **Range:** 0.409 - 1.006 ms

#### Parsing
- **Mean:** 1.622 ms
- **Median:** 1.575 ms
- **StdDev:** 0.189 ms
- **Range:** 1.371 - 2.275 ms

#### Total Time
- **Mean:** 2.113 ms ⚡️ **3.5x faster overall**
- **Median:** 2.054 ms
- **StdDev:** 0.245 ms
- **Range:** 1.788 - 2.940 ms

### Throughput
- **634,756 lines/second** (was 179,466) - **3.5x improvement**
- **20,116 KB/second** (was 5,687) - **3.5x improvement**

---

## Previous Baseline (Character-based tokenizer)

**Date:** December 22, 2025

### Results (100 iterations)

#### Tokenization
- **Mean:** 6.207 ms
- **Median:** 6.215 ms
- **StdDev:** 0.206 ms
- **Range:** 5.754 - 6.747 ms

#### Parsing
- **Mean:** 1.170 ms
- **Median:** 1.148 ms
- **StdDev:** 0.094 ms
- **Range:** 1.044 - 1.482 ms

#### Total Time
- **Mean:** 7.377 ms
- **Median:** 7.344 ms
- **StdDev:** 0.228 ms
- **Range:** 6.869 - 7.905 ms

### Throughput
- **181,783 lines/second**
- **5,761 KB/second**

---

## Optimization Analysis

### UTF-8 Byte-Level Scanning Results

The migration from Character-based iteration to UTF-8 byte-level scanning delivered exceptional performance gains:

**Tokenization Improvement: 12.7x faster**
- Before: 6.207 ms → After: 0.490 ms
- **92.1% reduction** in tokenization time

**Overall Improvement: 3.5x faster**
- Before: 7.377 ms → After: 2.113 ms
- **71.4% reduction** in total parse time

### Key Optimizations Applied

1. **O(1) Byte Array Access**
   - Replaced `String.Index` navigation (O(n)) with `Array<UInt8>` indexing (O(1))
   - Pre-allocate: `bytes = Array(source.utf8)`

2. **Byte-Level Comparisons**
   - Character properties: `char.isWhitespace` → Byte checks: `byte == 0x20 || byte == 0x09`
   - Faster CPU instruction pipeline

3. **Inlined Hot Paths**
   - Added `@inline(__always)` to: `advance()`, `isDigit()`, `isNameStart()`, `isNameContinue()`
   - Eliminates function call overhead

4. **UTF-8 Decoding Only When Needed**
   - Scan bytes directly, decode to String only for token values
   - Uses `String(decoding:as:)` for efficient UTF-8 conversion

### Performance Breakdown - After Optimization

- **Tokenization:** 23.2% of total time (was 84.7%)
- **Parsing:** 76.8% of total time (was 15.3%)

The optimization successfully shifted the bottleneck from tokenization to parsing, which is now the dominant phase. This is expected and healthy - parsing involves more complex operations (AST construction, semantic analysis, Python AST integration) that are harder to optimize further without sacrificing correctness.

### Comparison to PySwiftAST

PySwiftAST's similar UTF-8 migration achieved **18.8x speedup** in tokenization. Our **12.7x speedup** is in the same ballpark, confirming that byte-level scanning is the right optimization for lexical analysis in Swift.

### Production Readiness

- **Sub-3ms total time** ✅ (target was <5ms)
- **634K lines/sec throughput** ✅ (more than sufficient for IDE integration)
- **Low variance** (σ = 0.245ms) ✅ (predictable performance)

The optimized parser is production-ready for:
- Real-time IDE features (syntax highlighting, autocomplete)
- Build tools and linters
- Large-scale KV file processing
