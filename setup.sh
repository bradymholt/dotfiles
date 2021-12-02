#!/bin/bash

echo "#######################"
echo "BRADY'S DOTFILES SETUP"
echo "#######################"

DOTFILES_PATH=$(cd `dirname $0` && pwd)
CURRENT_SCRIPT_NAME=${0##*/}

echo ""
echo "STEP 1: Running brew bundle to install Homebrew packages"
brew bundle

echo ""
echo "STEP 2: Configure macOS preferences"
$DOTFILES_PATH/macOS.sh


echo ""
echo "STEP 3: Initialize secrets repo"
SECRETS_FOLDER="${DOTFILES_PATH}/secrets"
if [ -d "${SECRETS_FOLDER}" ]; then
  echo "The secrets repo has already initialized!"
else
  read -p "$(echo -e 'The secrets repo needs to be initialized.\nEnter the secrets HTTPS repo URL (i.e. https://gist.github.com/daec9fb6743NOT-REALe49f43a5.git): ')" SECRETS_REPO_URL
  git clone $SECRETS_REPO_URL $SECRETS_FOLDER
fi

# [Re]create symbolic links from $HOME to ./*
# Only top level files/directories will be symlinked
echo ""
echo "STEP 4: symlink files from ${HOME} to ${DOTFILES_PATH}/"
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
find $DOTFILES_PATH -maxdepth 1 -mindepth 1 \( ! -iname "dotfiles*" ! -iname ".git" ! -iname ".gitignore" ! -iname "README.md" ! -iname "LaunchAgents" \) -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

# [Re]create specialized symbolic links
echo ""
echo "STEP 5: specialized symlinks" 
# ~/Library/LaunchAgents to ./LaunchAgents/*¬
find $DOTFILES_PATH/LaunchAgents -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/Library/LaunchAgents ';'
# ~/Library/Services to ./Services/*¬
find $DOTFILES_PATH/Services -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/Library/Services ';'
# iTerm
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/iterm2.plist" "${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
# VS Code
mkdir -p "${HOME}/Library/Application Support/Code/User"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
mkdir -p "${HOME}/Library/Application Support/Code/User/snippets"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.code-snippets" "${HOME}/Library/Application Support/Code/User/snippets/code-snippets.code-snippets"
# SSH keypair
mkdir -p "${HOME}/.ssh"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa" "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa.pub" "${HOME}/.ssh/id_rsa.pub"

echo ""
echo "STEP 6: Running npm install in bin/ folder to install Node dependencies"
npm --prefix "$DOTFILES_PATH/bin" install "$DOTFILES_PATH/bin"