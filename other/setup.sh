#!/bin/bash

SCRIPT_PATH=$(cd `dirname $0` && pwd)
LINK_TARGET_EXISTS_HANDLING=$1

# crontab
echo "Replacing user crontab with ${SCRIPT_PATH}/crontab"
crontab $SCRIPT_PATH/crontab

# VS Code
ln -sv${LINK_TARGET_EXISTS_HANDLING} $SCRIPT_PATH/vscode-settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

# BetterSnapTool config - The format of the config is complicated so if something ever
# goes wrong and manual config is needed, here is a screenshot of the important settings: https://cloud.githubusercontent.com/assets/759811/15751225/f76b950c-28ae-11e6-9fd9-7c83aad698b2.png 
ln -sv${LINK_TARGET_EXISTS_HANDLING} $SCRIPT_PATH/com.hegenberg.BetterSnapTool.plist "${HOME}/Library/Preferences/com.hegenberg.BetterSnapTool.plist"