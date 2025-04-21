#!/bin/bash

# Auto Git Commit & Push Script for https://github.com/vishal1142/java.git

# Default commit message with timestamp
DEFAULT_COMMIT_MSG="Auto-commit to java repo on $(date '+%Y-%m-%d %H:%M:%S')"

# Ask user for a custom commit message
read -p "Enter commit message (or press Enter for default): " COMMIT_MSG

# Use default if input is empty
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="$DEFAULT_COMMIT_MSG"
fi

# Add and commit changes
git add .
git commit -m "$COMMIT_MSG"

# Ensure the correct remote is set
git remote set-url origin https://github.com/vishal1142/java.git

# Get default branch (main/master)
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')

# Push changes to the correct branch
git push origin "$DEFAULT_BRANCH"

# Output summary
echo "✅ Code pushed to GitHub!"
echo "Repository: https://github.com/vishal1142/java.git"
echo "Branch: $DEFAULT_BRANCH"
echo "Commit message: $COMMIT_MSG"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "----------------------------------------"
echo "Push completed successfully!"
echo "----------------------------------------"
echo "Visit your repo to see the changes."
echo "----------------------------------------"
echo "Happy coding! 🚀"
