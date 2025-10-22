#!/usr/bin/env python3
"""
Remove GDS and Lab 7/17 references from Neo4j presentations
"""

import re
from pathlib import Path

PRESENTATIONS_DIR = Path("/Users/jwkidd3/classes_in_development/neo4j_mastering/presentations")

def remove_gds_from_presentation_1():
    """Remove GDS references from presentation 1"""
    file_path = PRESENTATIONS_DIR / "neo4j_presentation_1.html"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove GDS line items
    content = re.sub(r'\s*<li><strong>GDS:</strong> Advanced graph algorithms</li>\n', '', content)
    content = re.sub(r'APOC, GDS, Bloom', 'APOC, Bloom', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✓ Updated {file_path.name}")

def remove_gds_from_presentation_2():
    """Remove GDS and Lab 7 references from presentation 2"""
    file_path = PRESENTATIONS_DIR / "neo4j_presentation_2.html"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove GDS references
    content = re.sub(r'Graph Data Science \| ', '', content)
    content = re.sub(r'\s*<li><strong>GDS Library:</strong> Production algorithms</li>\n', '', content)

    # Remove entire "Session 7: Graph Data Science & Machine Learning" slide
    content = re.sub(
        r'<!-- Session 7.*?</section>\s*</section>',
        '',
        content,
        flags=re.DOTALL
    )

    # Remove Lab 7 references
    content = re.sub(r'<!-- Graph Path Functions for Lab 7 -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Lab 7 Introduction -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<strong>Lab 7 Application:</strong>[^<]+', '', content)
    content = re.sub(r'graph algorithms, fraud detection, and predictive capabilities', 'fraud detection and predictive capabilities', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✓ Updated {file_path.name}")

def remove_lab17_from_presentation_3():
    """Remove Lab 17 and GDS references from presentation 3"""
    file_path = PRESENTATIONS_DIR / "neo4j_presentation_3.html"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove GDS certification reference
    content = re.sub(r'\s*<li><strong>Graph Data Science Certification:</strong> Advanced analytics and ML</li>\n', '', content)

    # Remove all Lab 17 slides (slides 59-63)
    content = re.sub(r'<!-- Slide 59: Lab 17 Introduction -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Slide 60: Lab 17 AI/ML Integration -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Slide 61: Lab 17 IoT Integration -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Slide 62: Lab 17 Blockchain Integration -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)
    content = re.sub(r'<!-- Slide 63: Lab 17 Advanced Visualization -->.*?</section>\s*</section>', '', content, flags=re.DOTALL)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✓ Updated {file_path.name}")

if __name__ == "__main__":
    print("Removing GDS and Lab 7/17 references from presentations...")
    remove_gds_from_presentation_1()
    remove_gds_from_presentation_2()
    remove_lab17_from_presentation_3()
    print("\n✅ All presentations updated successfully!")
