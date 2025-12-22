import Foundation
import KvParser

/// Performance benchmark for KV parser
/// Measures parse time for style.kv with statistical analysis

func benchmark() throws {
    // Load style.kv
    let resourcePath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Tests/KvParserTests/Resources/style.kv")
    
    let source = try String(contentsOf: resourcePath, encoding: .utf8)
    let sourceSize = source.utf8.count
    let lineCount = source.components(separatedBy: .newlines).count
    
    print("=== KV Parser Performance Benchmark ===")
    print("File: style.kv")
    print("Size: \(sourceSize) bytes")
    print("Lines: \(lineCount)")
    print()
    
    // Warmup runs
    print("Warming up...")
    for _ in 0..<3 {
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let parser = KvParser(tokens: tokens)
        _ = try parser.parse()
    }
    
    // Benchmark runs
    let iterations = 100
    var tokenizeTimes: [Double] = []
    var parseTimes: [Double] = []
    var totalTimes: [Double] = []
    
    print("Running \(iterations) iterations...")
    for i in 0..<iterations {
        let startTotal = CFAbsoluteTimeGetCurrent()
        
        // Tokenize
        let startTokenize = CFAbsoluteTimeGetCurrent()
        let tokenizer = KvTokenizer(source: source)
        let tokens = try tokenizer.tokenize()
        let tokenizeTime = (CFAbsoluteTimeGetCurrent() - startTokenize) * 1000
        
        // Parse
        let startParse = CFAbsoluteTimeGetCurrent()
        let parser = KvParser(tokens: tokens)
        let module = try parser.parse()
        let parseTime = (CFAbsoluteTimeGetCurrent() - startParse) * 1000
        
        let totalTime = (CFAbsoluteTimeGetCurrent() - startTotal) * 1000
        
        tokenizeTimes.append(tokenizeTime)
        parseTimes.append(parseTime)
        totalTimes.append(totalTime)
        
        // Progress indicator
        if (i + 1) % 10 == 0 {
            print("  \(i + 1)/\(iterations) completed...")
        }
        
        // Validate parse result (ensure we're not optimizing away the work)
        _ = module.rules.count
    }
    
    print()
    print("=== Results ===")
    print()
    
    // Calculate statistics
    func stats(_ times: [Double]) -> (mean: Double, stddev: Double, min: Double, max: Double, median: Double) {
        let mean = times.reduce(0, +) / Double(times.count)
        let variance = times.map { pow($0 - mean, 2) }.reduce(0, +) / Double(times.count)
        let stddev = sqrt(variance)
        let min = times.min() ?? 0
        let max = times.max() ?? 0
        let sorted = times.sorted()
        let median = sorted[sorted.count / 2]
        return (mean, stddev, min, max, median)
    }
    
    let tokenizeStats = stats(tokenizeTimes)
    let parseStats = stats(parseTimes)
    let totalStats = stats(totalTimes)
    
    print("Tokenization:")
    print("  Mean:   \(String(format: "%.3f", tokenizeStats.mean)) ms")
    print("  Median: \(String(format: "%.3f", tokenizeStats.median)) ms")
    print("  StdDev: \(String(format: "%.3f", tokenizeStats.stddev)) ms")
    print("  Min:    \(String(format: "%.3f", tokenizeStats.min)) ms")
    print("  Max:    \(String(format: "%.3f", tokenizeStats.max)) ms")
    print()
    
    print("Parsing:")
    print("  Mean:   \(String(format: "%.3f", parseStats.mean)) ms")
    print("  Median: \(String(format: "%.3f", parseStats.median)) ms")
    print("  StdDev: \(String(format: "%.3f", parseStats.stddev)) ms")
    print("  Min:    \(String(format: "%.3f", parseStats.min)) ms")
    print("  Max:    \(String(format: "%.3f", parseStats.max)) ms")
    print()
    
    print("Total:")
    print("  Mean:   \(String(format: "%.3f", totalStats.mean)) ms")
    print("  Median: \(String(format: "%.3f", totalStats.median)) ms")
    print("  StdDev: \(String(format: "%.3f", totalStats.stddev)) ms")
    print("  Min:    \(String(format: "%.3f", totalStats.min)) ms")
    print("  Max:    \(String(format: "%.3f", totalStats.max)) ms")
    print()
    
    // Throughput
    let throughputLinesPerSec = Double(lineCount) / (totalStats.mean / 1000.0)
    let throughputBytesPerSec = Double(sourceSize) / (totalStats.mean / 1000.0)
    print("Throughput:")
    print("  \(String(format: "%.0f", throughputLinesPerSec)) lines/sec")
    print("  \(String(format: "%.2f", throughputBytesPerSec / 1024)) KB/sec")
    print()
    
    // JSON output for tracking
    let results: [String: Any] = [
        "timestamp": ISO8601DateFormatter().string(from: Date()),
        "file": "style.kv",
        "size_bytes": sourceSize,
        "line_count": lineCount,
        "iterations": iterations,
        "tokenize_ms": [
            "mean": tokenizeStats.mean,
            "median": tokenizeStats.median,
            "stddev": tokenizeStats.stddev,
            "min": tokenizeStats.min,
            "max": tokenizeStats.max
        ],
        "parse_ms": [
            "mean": parseStats.mean,
            "median": parseStats.median,
            "stddev": parseStats.stddev,
            "min": parseStats.min,
            "max": parseStats.max
        ],
        "total_ms": [
            "mean": totalStats.mean,
            "median": totalStats.median,
            "stddev": totalStats.stddev,
            "min": totalStats.min,
            "max": totalStats.max
        ],
        "throughput": [
            "lines_per_sec": throughputLinesPerSec,
            "kb_per_sec": throughputBytesPerSec / 1024
        ]
    ]
    
    let jsonData = try JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    
    print("=== JSON Results ===")
    print(jsonString)
    
    // Save to file
    let outputPath = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("performance_baseline.json")
    
    try jsonData.write(to: outputPath)
    print()
    print("Results saved to: performance_baseline.json")
}

// Run benchmark
do {
    try benchmark()
} catch {
    print("Error: \(error)")
    exit(1)
}
