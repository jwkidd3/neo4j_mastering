#!/usr/bin/env python3
"""
Renumber labs after removing Lab 7 and Lab 17
"""

import shutil
from pathlib import Path

LABS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/labs")
DATA_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/data")

# Mapping: old_number -> new_number
LAB_MAPPING = {
    8: 7,   # Performance Optimization
    9: 8,   # Fraud Detection
    10: 9,  # Compliance Audit
    11: 10, # Predictive Analytics
    12: 11,
    13: 12,
    14: 13,
    15: 14, # Production Deployment
    16: 15,
}

def renumber_labs():
    """Rename lab files from old numbers to new numbers"""
    print("Renumbering lab files...")

    # Get all labs that need renumbering (in reverse order to avoid conflicts)
    for old_num in sorted(LAB_MAPPING.keys(), reverse=True):
        new_num = LAB_MAPPING[old_num]

        # Find all files with old number
        old_pattern = f"neo4j_lab_{old_num}*"
        old_files = list(LABS_DIR.glob(old_pattern))

        for old_file in old_files:
            # Create new filename
            old_name = old_file.name
            new_name = old_name.replace(f"lab_{old_num}", f"lab_{new_num}")
            new_file = LABS_DIR / new_name

            print(f"  {old_name} → {new_name}")
            shutil.move(str(old_file), str(new_file))

    print("✓ Lab files renumbered")

def renumber_data_scripts():
    """Rename data reload scripts"""
    print("\nRenumbering data reload scripts...")

    for old_num in sorted(LAB_MAPPING.keys(), reverse=True):
        new_num = LAB_MAPPING[old_num]

        old_script = DATA_DIR / f"lab_{old_num:02d}_data_reload.cypher"
        new_script = DATA_DIR / f"lab_{new_num:02d}_data_reload.cypher"

        if old_script.exists():
            print(f"  {old_script.name} → {new_script.name}")
            shutil.move(str(old_script), str(new_script))

    print("✓ Data scripts renumbered")

def update_lab_content():
    """Update references inside lab files"""
    print("\nUpdating internal lab references...")

    all_labs = sorted(LABS_DIR.glob("neo4j_lab_*.md"))

    for lab_file in all_labs:
        with open(lab_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content

        # Update "Lab X" references in text
        for old_num in sorted(LAB_MAPPING.keys(), reverse=True):
            new_num = LAB_MAPPING[old_num]
            content = content.replace(f"Lab {old_num}", f"Lab {new_num}")
            content = content.replace(f"Lab {old_num}:", f"Lab {new_num}:")
            content = content.replace(f"**Lab {old_num}", f"**Lab {new_num}")

        # Update "Completion of Lab X" references
        for old_num in sorted(LAB_MAPPING.keys(), reverse=True):
            new_num = LAB_MAPPING[old_num]
            content = content.replace(f"Completion of Lab {old_num}", f"Completion of Lab {new_num}")

        if content != original:
            with open(lab_file, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Updated {lab_file.name}")

    print("✓ Lab content updated")

if __name__ == "__main__":
    print("=" * 60)
    print("LAB RENUMBERING SCRIPT")
    print("=" * 60)
    print("\nMapping:")
    for old, new in sorted(LAB_MAPPING.items()):
        print(f"  Lab {old} → Lab {new}")
    print()

    renumber_labs()
    renumber_data_scripts()
    update_lab_content()

    print("\n" + "=" * 60)
    print("✅ Renumbering complete!")
    print("=" * 60)
