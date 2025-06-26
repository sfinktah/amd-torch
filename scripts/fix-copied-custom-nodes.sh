#!/bin/bash

echo "Cleaning up compiled Python files..."

# Delete __pycache__ folders
find . -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null

# Delete .pyc and .pyo files
find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete 2>/dev/null

echo
echo "Searching for requirements.txt files..."

# Find requirements.txt in top-level subdirectories only
for dir in */ ; do
    if [[ -f "$dir/requirements.txt" ]]; then
        echo "----------------------------------------------------"
        echo "Found: $dir/requirements.txt"
        echo "Installing requirements in: $dir"
        (cd "$dir" && pip install -r requirements.txt)
    fi
done

echo
echo "All done."
