#!/bin/bash

# Move a file/directory from $HOME to link/ and create a symbolic link, in place of the original file

SCRIPT_PATH=$(cd `dirname $0` && pwd -P)
DOTFILES_PATH=$(cd ${SCRIPT_PATH}/../../ && pwd)
mv $HOME/${1} $DOTFILES_PATH/home/
ln -siv $DOTFILES_PATH/home/${1} $HOME/${1}

$DOTFILES_PATH/backup.sh