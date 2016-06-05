#!/bin/bash

echo "#######################"
echo "BRADY'S DOTFILES SETUP"
echo "#######################"

DOTFILES_PATH=$(cd `dirname $0` && pwd)

LINK_TARGET_EXISTS_HANDLING=""
while true; do
    read -p "$(echo -e 'If files exist or are already symlinked, do you want to replace?\nAnswer [y]es, [n]o, or [p]rompt: ')" yn
    case $yn in
        [Yy]* ) LINK_TARGET_EXISTS_HANDLING="f"; break;;
        [Nn]* ) LINK_TARGET_EXISTS_HANDLING=""; break;;
        [Pp]* ) LINK_TARGET_EXISTS_HANDLING="i"; break;;
        * ) echo "Please answer: ";;
    esac
done

echo ""
echo "STEP 1: Setup secrets folder"
SECRETS_FOLDER="${DOTFILES_PATH}/home/secrets"
if [ -d "${SECRETS_FOLDER}" ]; then
  echo "secrets folder already initialized"
else
  read -p "$(echo -e 'Enter secrets repo URL: ')" SECRETS_REPO_URL
  git clone $SECRETS_REPO_URL $SECRETS_FOLDER
fi
# [Re]create symbolic links from $HOME to ./link/*
# Only top level files/directories will be symlinked
echo ""
echo "STEP 2: Link files from ${HOME} to ${DOTFILES_PATH}/home"
find $DOTFILES_PATH/home -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

echo ""
echo "STEP 3: Symlinks for outside config"
# VS Code
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.vscode.settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
# BetterSnapTool config - The format of the config is complicated so if something ever goes wrong and manual config is needed, here is a screenshot of the important settings: https://cloud.githubusercontent.com/assets/759811/15751225/f76b950c-28ae-11e6-9fd9-7c83aad698b2.png 
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.BetterSnapTool" "${HOME}/Library/Preferences/com.hegenberg.BetterSnapTool.plist"

echo ""
echo "STEP 4: Crontab"
echo "backing up user crontab to /tmp/crontab.bk"
crontab -l > /tmp/crontab.bk
echo "Replacing user crontab with contents of ${HOME}/.crontab"
crontab ${HOME}/.crontab

