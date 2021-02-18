# dotfiles

This is my system configuration for macOS consisting of config "dotfiles" and shell scripts.

## Usage

- Clone this repo to a directory in the $HOME folder;
- Run `cd dotfiles`
- Run `./dotfiles-setup.sh`.  This idempotent script will:
  - Initialize `/secrets` folder (repo).  This is a separate repo that contains secrets that will not be commited/push to the same remote as the main dotfiles repo.
  - Create symlinks for all files and top level folders in $HOME/dotfiles.  For example, $HOME/.zshrc symlink will be created which will point to $HOME/dotfiles/.zshrc.
  - Create additional symlinks for applications that do not store config in $HOME.  For example, a symlink will be created from /Library/Application Support/Code/User/settings.json to $HOME/.vscode.settings.json so that VS Code will use config residing in dotfiles, even though the original config location is outsite of $HOME.
  - Create symlinks for ssh key: `/.ssh/id_rsa > ${HOME}/secrets/id_rsa` and `/.ssh/id_rsa.pub > ${HOME}/secrets/id_rsa.pub` targeting key stored in $HOME/dotfiles/secrets.
  - Replace current user crontab with contents of `/.crontab`
- `dotfiles-link.sh` -  If there are files in $HOME that you would like to be moved to the dotfiles repo, you can run `dotfiles-link.sh` and pass in the name of the file that resides in $HOME.  This will move the file to `/home` and create a symlink to it.

## Fresh macOS Setup

When setting up an macOS system initially, the following steps should be performed to get a base system setup.  **NOTE:** These steps should be performed before running `./dotfiles-setup.sh`

1. Install Homebrew - `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
1. Install apps: 
    ```
    brew tap homebrew/cask-fonts && brew tap jakehilborn/jakehilborn && \
    brew install git wget zsh bash vim jq node yarn heroku/brew/heroku postgres displayplacer switchaudio-osx && \
    brew install --cask font-meslo-lg iterm2 github google-chrome visual-studio-code slack docker beyond-compare rectangle franz db-browser-for-sqlite tablple cleanshot && \
    npm install --global pure-prompt
    ```
1. Find `id_rsa` file in 1Password and download to .ssh/id_rsa then run `chmod 600 ~/.ssh/id_rsa`
1. Tell iTerm2 to look at `~/.iterm` for settings
1. Follow steps in "Usage" section above
