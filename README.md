# dotfiles

This is my system configuration for macOS consisting of a Brewfile, config "dotfiles", and misc and shell scripts.

## Initial Setup

1. Install [Homebrew](https://brew.sh/) (using instructions on the homepage)
1. Run `brew install --cask 1password`
1. Open 1Password Desktop and login using Emergency Kit QR Code   
1. Clone this repo: `TARGET_DIR=$HOME/dotfiles; git clone https://github.com/bradymholt/dotfiles.git $TARGET_DIR && cd $TARGET_DIR`
1. Run setup script: `./setup.sh`

## Scripts

- `setup.sh` - This idempotent script bootstraps macOS (installs apps and configures preferences), ensures secrets repo is initialized, and symlinks dotfiles
- `backup.sh` - Backup dotfiles and secrets repos
- `link.sh` -  If there are files in $HOME that you would like to be moved to the dotfiles repo, you can run this script and pass in the name of the file that resides in $HOME.  This will move the file to the dotfiles directory and create a symlink to it.