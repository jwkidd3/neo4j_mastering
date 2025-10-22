#!/usr/bin/env python3
"""
Fix lab titles to match filename numbers
"""

import re
from pathlib import Path

LABS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/labs")

def fix_lab_titles():
    """Update lab titles to match their filename number"""
    print("Fixing lab titles to match filenames...")

    all_labs = sorted(LABS_DIR.glob("neo4j_lab_*.md"))

    for lab_file in all_labs:
        # Extract lab number from filename
        match = re.search(r'neo4j_lab_(\d+)', lab_file.name)
        if not match:
            print(f"  ! Skipping {lab_file.name} - could not extract lab number")
            continue

        correct_lab_num = int(match.group(1))

        with open(lab_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Update title header to match filename number
        content = re.sub(
            r'^# Neo4j Lab \d+:',
            f'# Neo4j Lab {correct_lab_num}:',
            content,
            count=1,
            flags=re.MULTILINE
        )

        # Update summary headers
        content = re.sub(
            r'## Neo4j Lab \d+ Summary',
            f'## Neo4j Lab {correct_lab_num} Summary',
            content,
            flags=re.MULTILINE
        )
        content = re.sub(
            r'## 📚 Lab \d+ Summary',
            f'## 📚 Lab {correct_lab_num} Summary',
            content,
            flags=re.MULTILINE
        )

        # Update "Lab X completion verification" patterns
        content = re.sub(
            rf'Lab \d+ (Database State|completion|Completion Verification)',
            f'Lab {correct_lab_num} \\1',
            content
        )

        if content != original:
            with open(lab_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Updated {lab_file.name} → Lab {correct_lab_num}")
        else:
            print(f"  - {lab_file.name} already correct (Lab {correct_lab_num})")

    print("✓ Lab titles fixed")

if __name__ == "__main__":
    print("=" * 60)
    print("FIX LAB TITLES SCRIPT")
    print("=" * 60)
    print()

    fix_lab_titles()

    print("\n" + "=" * 60)
    print("✅ Lab titles fixed!")
    print("=" * 60)
