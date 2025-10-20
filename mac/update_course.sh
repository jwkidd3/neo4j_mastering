#!/bin/bash
# Neo4j Mastering Course - Update Course Materials
# Mac/Linux version

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Go to course root (parent of mac directory)
COURSE_DIR="$(dirname "$SCRIPT_DIR")"

echo "Pulling latest changes from repository..."
cd "$COURSE_DIR"

git pull

if [ $? -eq 0 ]; then
    echo "✓ Pull complete!"
else
    echo "✗ Git pull failed"
    exit 1
fi
