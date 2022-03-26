#!/bin/bash

printf "\033[0;33m"
printf "\n#######################"
printf "\nBRADY'S DOTFILES SETUP"
printf "\n#######################"
printf "\033[0m\n"

DOTFILES_PATH=$(cd `dirname $0` && pwd)
CURRENT_SCRIPT_NAME=${0##*/}
LINK_TARGET_EXISTS_HANDLING=f # If files exist or are already symlinked, they will be replaced

echo -e "\nSTEP 1: Running brew bundle to install Homebrew packages"
brew bundle install --no-upgrade

echo -e "\nSTEP 2: Configure macOS preferences"
$DOTFILES_PATH/macOS-defaults.sh

echo -e "\nSTEP 3: Initialize secrets repo"
SECRETS_FOLDER="${DOTFILES_PATH}/.secrets"
if [ -d "${SECRETS_FOLDER}" ]; then
  echo "The secrets repo has already initialized!"
else
  read -p "$(echo -e 'The secrets repo needs to be initialized.\nEnter the secrets HTTPS repo URL (i.e. https://gist.github.com/daec9fb6743NOT-REALe49f43a5.git): ')" SECRETS_REPO_URL
  git clone $SECRETS_REPO_URL $SECRETS_FOLDER
fi

# [Re]create symbolic links from $HOME to ./*
# Only top level files/directories will be symlinked
echo -e "\nSTEP 4: symlink files from ${HOME} to ${DOTFILES_PATH}/"
find $DOTFILES_PATH -maxdepth 1 -mindepth 1 -name '\.*' ! -iname ".git" -iname ".ssh" -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

# [Re]create specialized symbolic links
echo -e "\nSTEP 5: specialized symlinks" 
# LaunchAgents and Services
mkdir -p ~/Library/LaunchAgents
find $DOTFILES_PATH/LaunchAgents -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/Library/LaunchAgents/ ';'
find $DOTFILES_PATH/Services -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} ~/Library/Services ';'
# VS Code
mkdir -p "${HOME}/Library/Application Support/Code/User"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.settings.json" "${HOME}/Library/Application Support/Code/User/settings.json"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
mkdir -p "${HOME}/Library/Application Support/Code/User/snippets"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${DOTFILES_PATH}/vscode.code-snippets" "${HOME}/Library/Application Support/Code/User/snippets/code-snippets.code-snippets"
# SSH keypair
mkdir -p "${HOME}/.ssh"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.secrets/id_rsa" "${HOME}/.ssh/id_rsa"
chmod 600 "${HOME}/.ssh/id_rsa"
ln -sv${LINK_TARGET_EXISTS_HANDLING} "${HOME}/.secrets/id_rsa.pub" "${HOME}/.ssh/id_rsa.pub"

echo -e "\nSTEP 6: Misc other setup"
echo "Running npm install in bin/ folder to install Node dependencies..."
npm --prefix "$DOTFILES_PATH/bin" install "$DOTFILES_PATH/bin" &>/dev/null
echo "Importing Retangle settings"
defaults import com.knollsoft.Rectangle "${DOTFILES_PATH}/com.knollsoft.Rectangle.defaults"
echo "Importing Retangle settings"
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${DOTFILES_PATH}"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

printf "\n\033[0;32mDone!\n"