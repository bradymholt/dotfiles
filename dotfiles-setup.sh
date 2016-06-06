#!/bin/bash

echo "#######################"
echo "BRADY'S DOTFILES SETUP"
echo "#######################"

DOTFILES_PATH=$(cd `dirname $0` && pwd)
CURRENT_SCRIPT_NAME=${0##*/}

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
echo "STEP 1: Initialize secrets repo"
SECRETS_FOLDER="${DOTFILES_PATH}/secrets"
if [ -d "${SECRETS_FOLDER}" ]; then
  echo "The secrets repo has already initialized!"
else
  read -p "$(echo -e 'The secrets repo needs to be initialized.\nEnter the secrets repo URL (i.e. https://gist.github.com/bradyholt/123456): ')" SECRETS_REPO_URL
  git clone $SECRETS_REPO_URL $SECRETS_FOLDER
fi

# [Re]create symbolic links from $HOME to ./*
# Only top level files/directories will be symlinked
echo ""
echo "STEP 2: symlink files from ${HOME} to ${DOTFILES_PATH}/"
find $DOTFILES_PATH -maxdepth 1 -mindepth 1 \( ! -iname "dotfiles*" ! -iname ".git" ! -iname ".gitignore" ! -iname "README.md" \) -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

echo ""
echo "STEP 3: symlink external config"
# VS Code
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.vscode.settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"

# BetterSnapTool config - The format of the config is complicated so if something ever goes wrong and manual config is needed, here is a screenshot of the important settings: https://cloud.githubusercontent.com/assets/759811/15751225/f76b950c-28ae-11e6-9fd9-7c83aad698b2.png 
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.BetterSnapTool" "${HOME}/Library/Preferences/com.hegenberg.BetterSnapTool.plist"

echo ""
echo "STEP 3: symlink ssh key to ${HOME}/secrets/id_rsa[.pub]"
#Key pairs
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa" "${HOME}/.ssh/id_rsa"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa.pub" "${HOME}/.ssh/id_rsa.pub"

echo ""
echo "STEP 4: Setup crontab"
echo "backing up user crontab to /tmp/crontab.bk"
crontab -l > /tmp/crontab.bk
echo "Replacing user crontab with contents of ${HOME}/.crontab"
crontab ${HOME}/.crontab
echo "NOTE: Because of an OS X security block, you will need to manually make a material change to your crontab before it will be installed."
echo "Your crontab will be opened next; you should make a material change (i.e. add a comment on a new line) and save it"
read -p "Press any key to continue"
crontab -e
