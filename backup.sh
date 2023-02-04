#!/bin/bash

# Backup dotfiles and secrets repos

CURRENT_SCRIPT_PATH=$(cd `dirname $0` && pwd -P)
DOTFILES_PATH=$(cd ${CURRENT_SCRIPT_PATH}/ && pwd)
SECRETS_FOLDER="${DOTFILES_PATH}/.secrets"

echo ""
echo "STEP 1: Dumping Homebrew config to Brewfile"
cd $DOTFILES_PATH;
brew bundle dump --force

echo ""
echo "STEP 2: Commit and push dotfiles repo to origin"
cd $DOTFILES_PATH;
git add -A && git commit -m "Backup"; git push --quiet

echo ""
echo "STEP 3: Commit and push secrets repo to origin"
cd $SECRETS_FOLDER;
git add -A && git commit -m "Backup"; git push --quiet