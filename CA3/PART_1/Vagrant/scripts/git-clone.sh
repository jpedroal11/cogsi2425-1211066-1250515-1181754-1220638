#!/usr/bin/env bash
set -e

# Default target directory
PROJ_DIR="${PROJ_DIR:-/home/vagrant}"
REPO_NAME="cogsi2425-1211066-1250515-1181754-1220638"
REPO_URL="git@github.com:jpedroal11/${REPO_NAME}.git"
BRANCH_NAME="feature/vagrant-prt1"

echo "==== Cloning project repository ===="

# Ensure known_hosts contains GitHub’s fingerprint to avoid prompt
mkdir -p ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null

if [ -d "$PROJ_DIR/$REPO_NAME/.git" ]; then
    echo "Repository already exists — fetching latest changes..."
    cd "$PROJ_DIR/$REPO_NAME"
    git fetch origin
else
    echo "Cloning new repository into $PROJ_DIR"
    mkdir -p "$PROJ_DIR"
    git clone "$REPO_URL" "$PROJ_DIR/$REPO_NAME"
    cd "$PROJ_DIR/$REPO_NAME"
fi

# Checkout the desired branch safely
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    git checkout "$BRANCH_NAME"
    git pull origin "$BRANCH_NAME"
else
    git checkout -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
fi

cd "$PROJ_DIR/$REPO_NAME"
echo "Repository cloned or updated successfully on branch '$BRANCH_NAME'."
