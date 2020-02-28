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
  read -p "$(echo -e 'The secrets repo needs to be initialized.\nEnter the secrets SSH repo URL (i.e. git@gist.github.com:fc1c4b.git): ')" SECRETS_REPO_URL
  git clone $SECRETS_REPO_URL $SECRETS_FOLDER
fi

# [Re]create symbolic links from $HOME to ./*
# Only top level files/directories will be symlinked
echo ""
echo "STEP 2: symlink files from ${HOME} to ${DOTFILES_PATH}/"
find $DOTFILES_PATH -maxdepth 1 -mindepth 1 \( ! -iname "dotfiles*" ! -iname ".git" ! -iname ".gitignore" ! -iname "README.md" ! -iname "LaunchAgents" \) -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

# [Re]create specialized symbolic links
echo ""
echo "STEP 3: specialized symlinks" 
# ~/Library/LaunchAgents to ./LaunchAgents/*¬
find $DOTFILES_PATH/LaunchAgents -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/Library/LaunchAgents ';'
# VS Code
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.vscode.settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.vscode.keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.vscode.code-snippets" "${HOME}/Library/Application Support/Code/User/snippets/code-snippets.code-snippets"
# oh-my-zsh themes
find $DOTFILES_PATH/.zsh/oh-my-zsh-themes -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/.oh-my-zsh/themes ';'
# SSH keypair
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa" "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/secrets/id_rsa.pub" "${HOME}/.ssh/id_rsa.pub"

echo ""
echo "STEP 4: Running npm install in bin/ folder to install Node dependencies"
npm --prefix "$DOTFILES_PATH/bin" install "$DOTFILES_PATH/bin"