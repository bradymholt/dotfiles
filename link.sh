#!/bin/bash

# Move a file/directory from $HOME to ${DOTFILES_PATH} and create a symbolic link in place of the original file
# Example: # dotfiles/link.sh .tigrc

CURRENT_SCRIPT_PATH=$(cd `dirname $0` && pwd -P)
DOTFILES_PATH=$(cd ${CURRENT_SCRIPT_PATH}/ && pwd)
FILE_TO_LINK=$HOME/$1
mv $FILE_TO_LINK $DOTFILES_PATH/
ln -siv $DOTFILES_PATH/${1} $FILE_TO_LINK