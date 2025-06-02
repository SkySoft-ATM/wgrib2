#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1

# Set your fork details
FORK_REMOTE="origin"          # Your fork remote (usually 'origin')
UPSTREAM_REMOTE="upstream"    # Upstream remote name (can be 'upstream' or whatever you call it)
BRANCH="develop"              # The branch to sync, e.g., 'develop'

# Ensure you have both remotes configured
git remote add $UPSTREAM_REMOTE https://github.com/NOAA-EMC/wgrib2.git 2> /dev/null || echo "Upstream already added"

# Fetch latest changes from upstream
git fetch $UPSTREAM_REMOTE

# Create a new branch for the update
SYNC_BRANCH="sync-upstream-$(date +%Y%m%d%H%M%S)"
git checkout -b $SYNC_BRANCH $FORK_REMOTE/$BRANCH

# Merge the upstream changes
git merge $UPSTREAM_REMOTE/$BRANCH --no-ff --no-edit

# Push the sync branch to your fork
git push $FORK_REMOTE $SYNC_BRANCH

# Create a Pull Request using GitHub CLI (ensure 'gh' is installed and authenticated)
gh pr create --base $BRANCH --head $SYNC_BRANCH --title "Sync with upstream $BRANCH" --body "Automated sync of upstream repository $UPSTREAM_REMOTE/$BRANCH into fork branch $BRANCH."

echo "Pull request created from $SYNC_BRANCH to $BRANCH on your fork."

