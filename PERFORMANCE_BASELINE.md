# Performance Baseline

## Swift KV Parser - Initial Baseline

**Date:** December 22, 2025  
**Hardware:** Apple Silicon (M-series)  
**Build:** Release mode (`-c release`)  
**File:** style.kv (1,341 lines, 43,518 bytes)

### Results (100 iterations)

#### Tokenization
- **Mean:** 6.327 ms
- **Median:** 6.262 ms
- **StdDev:** 0.510 ms
- **Range:** 5.744 - 10.712 ms

#### Parsing
- **Mean:** 1.145 ms
- **Median:** 1.139 ms
- **StdDev:** 0.077 ms
- **Range:** 1.035 - 1.484 ms

#### Total Time
- **Mean:** 7.472 ms
- **Median:** 7.402 ms
- **StdDev:** 0.549 ms
- **Range:** 6.801 - 12.196 ms

### Throughput
- **179,466 lines/second**
- **5,687 KB/second**

### Analysis

The Swift implementation shows excellent performance:

1. **Fast tokenization** (~6.3ms): YAML-inspired indentation detection with regex pattern matching
2. **Very fast parsing** (~1.1ms): Efficient recursive descent with minimal allocations
3. **Consistent performance**: Low standard deviation indicates stable performance
4. **Good throughput**: ~180K lines/sec is suitable for real-time IDE integration

### Performance Breakdown

- **Tokenization:** 84.7% of total time
- **Parsing:** 15.3% of total time

The tokenization phase dominates, which is expected for a lexer doing:
- Line-by-line scanning
- Regex pattern matching for tokens
- YAML-style indent/dedent detection
- String literal parsing with escapes

### Next Steps

1. **Profile tokenization hotspots** - Focus optimization here since it's 85% of total time
2. **Apply safe optimizations:**
   - Use `Array.reserveCapacity()` for token arrays
   - Minimize string copying in tokenizer
   - Consider character-at-a-time parsing for common tokens
3. **Target:** Sub-5ms total time (>40% improvement)

### Comparison Notes

For reference, typical Python parser performance (interpreted):
- Expected: 15-30ms for similar file (estimated 2-4x slower)
- Swift compiled performance advantage is significant
- Makes Swift implementation ideal for IDE integration

The current baseline is already production-ready for most use cases.
