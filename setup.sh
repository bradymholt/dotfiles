#!/bin/bash

# [Re]create symbolic links from $HOME to ./link/*
# Only top level files/directories will be symlinked
DOTFILES_PATH=$(cd `dirname $0` && pwd)
find $DOTFILES_PATH/home -maxdepth 1 -mindepth 1 -exec ln -siv {} $HOME ';'

# Run ./other/setup.sh with will handle symlinking config outside of $HOME
$DOTFILES_PATH/other/setup.sh