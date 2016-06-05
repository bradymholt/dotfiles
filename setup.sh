#!/bin/bash

echo "#######################"
echo "BRADY'S DOTFILES SETUP"
echo "#######################"

DOTFILES_PATH=$(cd `dirname $0` && pwd)
LINK_TARGET_EXISTS_HANDLING=""
while true; do
    read -p "$(echo -e 'Blah? Answer [y]es, [n]o, or [p]rompt: ')" yn
    case $yn in
        [Yy]* ) LINK_TARGET_EXISTS_HANDLING="f"; break;;
        [Nn]* ) LINK_TARGET_EXISTS_HANDLING=""; break;;
        [Pp]* ) LINK_TARGET_EXISTS_HANDLING="i"; break;;
        * ) echo "Please answer: ";;
    esac
done

echo ""
echo "STEP 1: Setup secure folder"
if [ -d "${DOTFILES_PATH}/home/secure" ]; then
  echo "secure folder already initialized"
else
  read -p "$(echo -e 'Enter secure repo URL: ')" SECURE_REPO_URL
  git clone $SECURE_REPO_URL ./home/secure
fi
# [Re]create symbolic links from $HOME to ./link/*
# Only top level files/directories will be symlinked
echo ""
echo "STEP 2: Link files from ${HOME} to ${DOTFILES_PATH}/home"
find $DOTFILES_PATH/home -maxdepth 1 -mindepth 1 -exec ln -sv${LINK_TARGET_EXISTS_HANDLING} {} $HOME ';'

echo ""
echo "STEP 3: Setup config from /other"
# Run ./other/setup.sh with will handle symlinking config outside of $HOME
$DOTFILES_PATH/other/setup.sh