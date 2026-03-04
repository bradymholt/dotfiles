#!/bin/bash

# Move a file/directory from $HOME to ${DOTFILES_PATH} (or .secrets with --secret) and create a symbolic link in place of the original file
# Example: dotfiles/link.sh .tigrc
# Example: dotfiles/link.sh --secret .ssh/id_rsa

CURRENT_SCRIPT_PATH=$(cd `dirname $0` && pwd -P)
DOTFILES_PATH=$(cd ${CURRENT_SCRIPT_PATH}/ && pwd)

TARGET_DIR=$DOTFILES_PATH
for arg in "$@"; do
  if [ "$arg" = "--secret" ]; then
    TARGET_DIR=$DOTFILES_PATH/.secrets
  else
    FILENAME=$arg
  fi
done

FILE_TO_LINK=$HOME/$FILENAME
mv $FILE_TO_LINK $TARGET_DIR/
ln -siv $TARGET_DIR/${FILENAME} $FILE_TO_LINK
