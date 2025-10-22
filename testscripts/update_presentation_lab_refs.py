#!/usr/bin/env python3
"""
Update lab references in presentations after renumbering
"""

import re
from pathlib import Path

PRESENTATIONS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/presentations")

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

def update_presentations():
    """Update lab references in all presentations"""
    print("Updating presentation lab references...")

    all_presentations = sorted(PRESENTATIONS_DIR.glob("neo4j_presentation_*.html"))

    for pres_file in all_presentations:
        with open(pres_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Use placeholder method to avoid replacement conflicts
        content = replace_with_placeholder(content, LAB_MAPPING)

        # Remove references to non-existent Lab 16 and Lab 17
        content = re.sub(
            r'<li><strong>Lab 16[^<]*</strong>[^<]*</li>\s*',
            '',
            content
        )
        content = re.sub(
            r'<li><strong>Lab 17[^<]*</strong>[^<]*</li>\s*',
            '',
            content
        )

        if content != original:
            with open(pres_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Updated {pres_file.name}")
        else:
            print(f"  - No changes needed in {pres_file.name}")

    print("✓ Presentation lab references updated")

if __name__ == "__main__":
    print("=" * 60)
    print("PRESENTATION LAB REFERENCE UPDATE SCRIPT")
    print("=" * 60)
    print("\nMapping:")
    for old, new in sorted(LAB_MAPPING.items()):
        print(f"  Lab {old} → Lab {new}")
    print()

    update_presentations()

    print("\n" + "=" * 60)
    print("✅ Presentation updates complete!")
    print("=" * 60)
