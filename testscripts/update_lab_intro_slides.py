#!/usr/bin/env python3
"""
Update lab introduction slides to include lab numbers
"""

import re
from pathlib import Path

PRESENTATIONS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/presentations")

def update_lab_intro_slides():
    """Update lab introduction slide headings to include lab numbers"""
    print("Updating lab introduction slide headings...")

    all_presentations = sorted(PRESENTATIONS_DIR.glob("neo4j_presentation_*.html"))

    for pres_file in all_presentations:
        with open(pres_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Pattern 1: "Lab Introduction:" without number → "Lab X Introduction:"
        # This catches cases like "🔧 Lab Introduction: Performance Optimization"
        # and converts to "🔧 Lab 7 Introduction: Performance Optimization"

        # We need to look for the comment before the slide that says "<!-- Lab X Introduction -->"
        # and update the h2 heading on the line below it

        # Find all lab introduction sections and update them
        pattern = r'<!-- Lab (\d+) Introduction -->\s*\n\s*<section>\s*\n\s*<div class="lab-intro">\s*\n\s*<h2>🔧 Lab Introduction:([^<]+)</h2>'

        def replace_heading(match):
            lab_num = match.group(1)
            topic = match.group(2).strip()
            return f'''<!-- Lab {lab_num} Introduction -->
            <section>
                <div class="lab-intro">
                    <h2>🔧 Lab {lab_num} Introduction: {topic}</h2>'''

        content = re.sub(pattern, replace_heading, content)

        if content != original:
            with open(pres_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Updated {pres_file.name}")
        else:
            print(f"  - No changes needed in {pres_file.name}")

    print("✓ Lab introduction slides updated")

if __name__ == "__main__":
    print("=" * 60)
    print("LAB INTRODUCTION SLIDE UPDATE SCRIPT")
    print("=" * 60)
    print()

    update_lab_intro_slides()

    print("\n" + "=" * 60)
    print("✅ Lab introduction slides updated!")
    print("=" * 60)
