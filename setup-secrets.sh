#!/bin/bash

# Setup script for adding Docker Hub secrets to GitHub repository
# Run this script after cloning the repository

set -e

echo "🚀 Setting up Docker Hub secrets for WineReaper repository"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub CLI first:"
    echo "   gh auth login"
    exit 1
fi

# Get repository info
REPO_OWNER="schnicklfritz"
REPO_NAME="winereaper"

echo "📦 Repository: $REPO_OWNER/$REPO_NAME"

# Add Docker Hub secrets
echo "🔐 Adding Docker Hub secrets..."

# Add DOCKERHUB_USERNAME
echo -n "Enter DOCKERHUB_USERNAME [schnicklbob]: "
read -r DOCKERHUB_USERNAME
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME:-schnicklbob}

gh secret set DOCKERHUB_USERNAME --repo="$REPO_OWNER/$REPO_NAME" --body="$DOCKERHUB_USERNAME"
echo "✅ Added DOCKERHUB_USERNAME secret"

# Add DOCKERHUB_TOKEN
echo -n "Enter DOCKERHUB_TOKEN: "
read -s DOCKERHUB_TOKEN
echo

if [ -z "$DOCKERHUB_TOKEN" ]; then
    echo "⚠️  No token provided. Please enter your Docker Hub token."
    echo -n "Enter DOCKERHUB_TOKEN: "
    read -s DOCKERHUB_TOKEN
    echo
fi

gh secret set DOCKERHUB_TOKEN --repo="$REPO_OWNER/$REPO_NAME" --body="$DOCKERHUB_TOKEN"
echo "✅ Added DOCKERHUB_TOKEN secret"

echo ""
echo "🎉 Secrets setup complete!"
echo ""
echo "Next steps:"
echo "1. The GitHub Actions workflow will automatically trigger on push"
echo "2. Check the Actions tab in your repository:"
echo "   https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "3. Once built, pull the image:"
echo "   docker pull schnicklbob/winereaper:latest"
echo "4. Run the container:"
echo "   docker run --gpus all -p 6080:6080 schnicklbob/winereaper:latest"
