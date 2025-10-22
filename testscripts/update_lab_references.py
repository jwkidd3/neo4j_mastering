#!/usr/bin/env python3
"""
Update internal lab references after renumbering
"""

import re
from pathlib import Path

LABS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/labs")

# Mapping: old_number -> new_number
LAB_MAPPING = {
    8: 7,   # Performance Optimization
    9: 8,   # Fraud Detection
    10: 9,  # Compliance Audit
    11: 10, # Predictive Analytics
    12: 11, # Python Driver
    13: 12, # Production Insurance API
    14: 13, # Interactive Web Application
    15: 14, # Production Deployment
    16: 15, # Multi-Line Platform
}

def replace_with_placeholder(content, mapping):
    """Replace lab numbers using placeholders to avoid conflicts"""
    # First pass: replace with placeholders
    for old_num in mapping.keys():
        placeholder = f"LABNUM_{old_num}_PLACEHOLDER"
        content = re.sub(
            rf'\bLab {old_num}\b',
            f'Lab {placeholder}',
            content
        )

    # Second pass: replace placeholders with new numbers
    for old_num, new_num in mapping.items():
        placeholder = f"LABNUM_{old_num}_PLACEHOLDER"
        content = content.replace(f'Lab {placeholder}', f'Lab {new_num}')

    return content

def update_lab_content():
    """Update references inside lab files"""
    print("Updating internal lab references...")

    all_labs = sorted(LABS_DIR.glob("neo4j_lab_*.md"))

    for lab_file in all_labs:
        with open(lab_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Use placeholder method to avoid replacement conflicts
        content = replace_with_placeholder(content, LAB_MAPPING)

        # Remove references to non-existent Lab 16 (from old Lab 15)
        content = re.sub(
            r'➡️\s+Next: Lab 16[^\n]*\n',
            '',
            content
        )
        content = re.sub(
            r'🔜 Ready for Lab 16[^\n]*\n',
            '',
            content
        )
        content = re.sub(
            r'\*\*Next Lab:\*\* Lab 16[^\n]*\n',
            '',
            content
        )

        if content != original:
            with open(lab_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Updated {lab_file.name}")
        else:
            print(f"  - No changes needed in {lab_file.name}")

    print("✓ Lab content updated")

if __name__ == "__main__":
    print("=" * 60)
    print("LAB REFERENCE UPDATE SCRIPT")
    print("=" * 60)
    print("\nMapping:")
    for old, new in sorted(LAB_MAPPING.items()):
        print(f"  Lab {old} → Lab {new}")
    print()

    update_lab_content()

    print("\n" + "=" * 60)
    print("✅ Reference updates complete!")
    print("=" * 60)
