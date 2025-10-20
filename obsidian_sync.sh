#!/bin/bash

set -e

echo "== Obsidian Sync Script =="

# Step 1: Ask for local Repository path
read -rp "Enter your Obsidian Vault Path (local git repo): " REPO_DIR
read -rp "Enter sync interval in minutes (default 30): " MINUTES
INTERVAL=$(( (${MINTES:-30}) * 60 ))

if [ ! -d"$REPO_DIR/.git" ]; then
  echo "ERROR: $REPO_DIR is not a git repository";
  exit 1
fi

cd "$REPO_DIR"

# Step 2: Continuous Sync Loop
while true; do
  echo
  echo "== Syncing notes at $(date) =="

  # Pull latest changes (in case synced from another device)
  git fetch origin
  git pull --rebase origin main 2>/dev/null || git pull --rebase origin master 2>/dev/null || true

  # Check for changes
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "-> Changes detected, committing..."
    git add -A
    git commit -m "Auto sync: $(date '+%Y-%m-%d %H:%M:%S')" || true
    git push origin HEAD
    echo "Pushed new changes."
  else
    echo "No new changes."
  fi

  echo "Sleeping for $INTERVAL seconds..."
  sleep "$INTERVAL"
done