#!/usr/bin/env python3
"""
Neo4j Mastering Course - Master Test Runner
Runs all 17 lab tests in sequence and generates a comprehensive report
"""

import sys
import subprocess
import time
from datetime import datetime
from pathlib import Path


class TestRunner:
    """Master test runner for all 17 labs"""

    def __init__(self):
        self.test_dir = Path(__file__).parent
        self.results = {}
        self.start_time = None
        self.end_time = None

    def run_all_tests(self):
        """Run all 17 lab tests"""
        print("="*80)
        print("NEO4J MASTERING COURSE - COMPREHENSIVE TEST SUITE")
        print("="*80)
        print(f"Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*80)

        self.start_time = time.time()

        # Define all test files in order
        test_files = [
            "test_lab_01_setup.py",
            "test_lab_02_cypher_fundamentals.py",
            "test_lab_03_claims_financial.py",
            "test_lab_04_bulk_import.py",
            "test_lab_05_advanced_analytics.py",
            "test_lab_06_customer_analytics.py",
            "test_lab_07_graph_algorithms.py",
            "test_lab_08_performance.py",
            "test_lab_09_fraud_detection.py",
            "test_lab_10_compliance.py",
            "test_lab_11_predictive.py",
            "test_lab_12_python_driver.py",
            "test_lab_13_api_development.py",
            "test_lab_14_production.py",
            "test_lab_15_integration.py",
            "test_lab_16_multiline.py",
            "test_lab_17_innovation.py"
        ]

        total_tests = len(test_files)
        passed_tests = 0
        failed_tests = 0

        for idx, test_file in enumerate(test_files, 1):
            lab_number = idx
            print(f"\n{'='*80}")
            print(f"Running Lab {lab_number:02d} Tests ({idx}/{total_tests}): {test_file}")
            print(f"{'='*80}")

            result = self.run_single_test(test_file)
            self.results[lab_number] = result

            if result['passed']:
                passed_tests += 1
                print(f"✓ Lab {lab_number:02d}: PASSED")
            else:
                failed_tests += 1
                print(f"✗ Lab {lab_number:02d}: FAILED")

        self.end_time = time.time()

        # Print final summary
        self.print_summary(total_tests, passed_tests, failed_tests)

        # Return exit code
        return 0 if failed_tests == 0 else 1

    def run_single_test(self, test_file):
        """Run a single test file"""
        test_path = self.test_dir / test_file
        result = {
            'test_file': test_file,
            'passed': False,
            'output': '',
            'error': '',
            'duration': 0
        }

        start = time.time()
        try:
            # Run pytest on the specific file
            process = subprocess.run(
                ['pytest', str(test_path), '-v', '--tb=short'],
                capture_output=True,
                text=True,
                timeout=120  # 2 minute timeout per test
            )

            result['output'] = process.stdout
            result['error'] = process.stderr
            result['passed'] = (process.returncode == 0)

            # Print output
            print(process.stdout)
            if process.stderr:
                print("STDERR:", process.stderr)

        except subprocess.TimeoutExpired:
            result['error'] = "Test timed out after 120 seconds"
            print(f"✗ ERROR: Test timed out")
        except Exception as e:
            result['error'] = str(e)
            print(f"✗ ERROR: {e}")

        result['duration'] = time.time() - start
        return result

    def print_summary(self, total, passed, failed):
        """Print comprehensive test summary"""
        duration = self.end_time - self.start_time

        print("\n" + "="*80)
        print("COMPREHENSIVE TEST SUITE SUMMARY")
        print("="*80)
        print(f"Total Duration: {duration:.2f} seconds ({duration/60:.2f} minutes)")
        print(f"Total Labs Tested: {total}")
        print(f"Labs Passed: {passed}")
        print(f"Labs Failed: {failed}")
        print(f"Success Rate: {(passed/total*100):.1f}%")
        print("="*80)

        print("\nLab-by-Lab Results:")
        print("-"*80)
        for lab_num in sorted(self.results.keys()):
            result = self.results[lab_num]
            status = "✓ PASS" if result['passed'] else "✗ FAIL"
            duration = result['duration']
            print(f"  Lab {lab_num:02d}: {status:8s} ({duration:.2f}s)")

        print("="*80)

        if failed > 0:
            print("\n⚠ WARNING: Some labs failed validation")
            print("Review the output above for details on failures")
        else:
            print("\n✓✓✓ SUCCESS: ALL LABS PASSED VALIDATION ✓✓✓")
            print("The Neo4j Mastering Course is ready for delivery!")

        print("="*80)

    def run_specific_lab(self, lab_number):
        """Run tests for a specific lab"""
        test_file = f"test_lab_{lab_number:02d}_*.py"
        print(f"Running tests for Lab {lab_number}...")
        # Implementation would use glob to find the right file
        pass

    def run_day_tests(self, day_number):
        """Run tests for a specific day"""
        day_ranges = {
            1: range(1, 6),    # Labs 1-5
            2: range(6, 12),   # Labs 6-11
            3: range(12, 18)   # Labs 12-17
        }

        if day_number not in day_ranges:
            print(f"Error: Invalid day number {day_number}")
            return 1

        print(f"Running Day {day_number} tests (Labs {list(day_ranges[day_number])[0]}-{list(day_ranges[day_number])[-1]})")
        # Implementation would run specific range
        pass


def main():
    """Main entry point"""
    runner = TestRunner()

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == '--lab' and len(sys.argv) > 2:
            lab_num = int(sys.argv[2])
            return runner.run_specific_lab(lab_num)

        elif command == '--day' and len(sys.argv) > 2:
            day_num = int(sys.argv[2])
            return runner.run_day_tests(day_num)

        elif command == '--help':
            print("Usage:")
            print("  python test_runner.py              # Run all tests")
            print("  python test_runner.py --lab N      # Run tests for Lab N")
            print("  python test_runner.py --day N      # Run tests for Day N (1, 2, or 3)")
            print("  python test_runner.py --help       # Show this help")
            return 0

    # Default: run all tests
    return runner.run_all_tests()


if __name__ == "__main__":
    sys.exit(main())
