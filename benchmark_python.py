#!/usr/bin/env python3
"""
Performance benchmark for Python KV parser (Kivy's parser.py)
Compares with Swift implementation baseline
"""

import sys
import time
import json
from pathlib import Path
from statistics import mean, stdev, median

# Add kivy to path
sys.path.insert(0, str(Path(__file__).parent / 'kivy'))

try:
    from kivy.lang import Parser
except ImportError:
    print("Error: Could not import Kivy. Make sure 'kivy' folder exists.")
    sys.exit(1)

def benchmark():
    # Load style.kv
    kv_path = Path(__file__).parent / 'Tests/KvParserTests/Resources/style.kv'
    source = kv_path.read_text(encoding='utf-8')
    source_size = len(source.encode('utf-8'))
    line_count = len(source.splitlines())
    
    print("=== Python KV Parser Performance Benchmark ===")
    print(f"File: style.kv")
    print(f"Size: {source_size} bytes")
    print(f"Lines: {line_count}")
    print()
    
    # Warmup
    print("Warming up...")
    for _ in range(3):
        parser = Parser(content=source, filename='style.kv')
    
    # Benchmark runs
    iterations = 100
    parse_times = []
    
    print(f"Running {iterations} iterations...")
    for i in range(iterations):
        start = time.perf_counter()
        parser = Parser(content=source, filename='style.kv')
        end = time.perf_counter()
        
        parse_time_ms = (end - start) * 1000
        parse_times.append(parse_time_ms)
        
        if (i + 1) % 10 == 0:
            print(f"  {i + 1}/{iterations} completed...")
    
    print()
    print("=== Results ===")
    print()
    
    mean_time = mean(parse_times)
    median_time = median(parse_times)
    stddev_time = stdev(parse_times)
    min_time = min(parse_times)
    max_time = max(parse_times)
    
    print(f"Parse Time:")
    print(f"  Mean:   {mean_time:.3f} ms")
    print(f"  Median: {median_time:.3f} ms")
    print(f"  StdDev: {stddev_time:.3f} ms")
    print(f"  Min:    {min_time:.3f} ms")
    print(f"  Max:    {max_time:.3f} ms")
    print()
    
    # Throughput
    throughput_lines = line_count / (mean_time / 1000.0)
    throughput_kb = (source_size / 1024) / (mean_time / 1000.0)
    
    print("Throughput:")
    print(f"  {throughput_lines:.0f} lines/sec")
    print(f"  {throughput_kb:.2f} KB/sec")
    print()
    
    # JSON output
    results = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "language": "python",
        "parser": "kivy.lang.Parser",
        "file": "style.kv",
        "size_bytes": source_size,
        "line_count": line_count,
        "iterations": iterations,
        "parse_ms": {
            "mean": mean_time,
            "median": median_time,
            "stddev": stddev_time,
            "min": min_time,
            "max": max_time
        },
        "throughput": {
            "lines_per_sec": throughput_lines,
            "kb_per_sec": throughput_kb
        }
    }
    
    print("=== JSON Results ===")
    print(json.dumps(results, indent=2))
    
    # Save to file
    output_path = Path(__file__).parent / 'performance_python.json'
    output_path.write_text(json.dumps(results, indent=2))
    print()
    print(f"Results saved to: performance_python.json")
    
    # Compare with Swift
    swift_path = Path(__file__).parent / 'performance_baseline.json'
    if swift_path.exists():
        swift_results = json.loads(swift_path.read_text())
        swift_total = swift_results['total_ms']['mean']
        speedup = mean_time / swift_total
        
        print()
        print("=== Comparison with Swift ===")
        print(f"Swift total time: {swift_total:.3f} ms")
        print(f"Python time:      {mean_time:.3f} ms")
        print(f"Swift is {speedup:.2f}x faster than Python")

if __name__ == '__main__':
    try:
        benchmark()
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
