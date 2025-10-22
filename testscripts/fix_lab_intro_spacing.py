#!/usr/bin/env python3
"""
Fix spacing in lab introduction slide headings
"""

import re
from pathlib import Path

PRESENTATIONS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/presentations")

def fix_spacing():
    """Fix spacing after colon in lab introduction headings"""
    print("Fixing spacing in lab introduction headings...")

    all_presentations = sorted(PRESENTATIONS_DIR.glob("neo4j_presentation_*.html"))

    for pres_file in all_presentations:
        with open(pres_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Fix: "Lab X Introduction:Topic" → "Lab X Introduction: Topic"
        # Pattern matches: 🔧 Lab X Introduction:Something (without space after colon)
        pattern = r'(🔧 Lab \d+ Introduction):([A-Z])'
        replacement = r'\1: \2'

        content = re.sub(pattern, replacement, content)

        if content != original:
            with open(pres_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Fixed spacing in {pres_file.name}")
        else:
            print(f"  - Spacing already correct in {pres_file.name}")

    print("✓ Spacing fixed")

if __name__ == "__main__":
    print("=" * 60)
    print("FIX LAB INTRODUCTION SPACING")
    print("=" * 60)
    print()

    fix_spacing()

    print("\n" + "=" * 60)
    print("✅ Spacing corrections complete!")
    print("=" * 60)
