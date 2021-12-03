#!/bin/bash

# Reference: https://github.com/mathiasbynens/dotfiles/blob/main/.macos

# Ask for the administrator password upfront
sudo -v

# Set host name
HOSTNAME=BradyHoltMBP
sudo scutil --set ComputerName $HOSTNAME
sudo scutil --set HostName $HOSTNAME
sudo scutil --set LocalHostName $HOSTNAME

# Trackpad: enable tap to click for this user and for the login screen
defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1

# Use scroll gesture with the Ctrl (⌘) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess closeViewSplitScreenRatio -string "0.2";
defaults write com.apple.universalaccess closeViewScrollWheelModifiersInt -int 1048576

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Do not reopen apps at login time
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true