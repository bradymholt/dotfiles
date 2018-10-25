# dotfiles

This is my system configuration for OS X consisting of config "dotfiles" and shell scripts.

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

## Fresh OS X Setup

When setting up an OS X system initially, the following steps should be performed to get a base system setup.  **NOTE:** These steps should be performed before running `./dotfiles-setup.sh`

1. Install [Homebrew](http://brew.sh/) and then install apps: `brew install git zsh bash vim jq node yarn heroku/brew/heroku postgres && brew tap caskroom/fonts && brew cask install font-meslo-lg iterm2 google-chrome visual-studio-code slack docker beyond-compare spectacle`
1. Install [1Password X](https://chrome.google.com/webstore/detail/1password-x-%E2%80%93-password-ma/aeblfdkhhhdcdjpifhhbdiojplfjncoa?hl=en) Chrome Extension and login
1. File `id_rsa` file in 1Password and download to .ssh/id_rsa then run `chmod 600 ~/.ssh/id_rsa`
1. Install these shell helpers:
   - [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) - `sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`
   - [RVM](https://rvm.io/rvm/install) - `\curl -sSL https://get.rvm.io | bash`
1. Install the following OS X apps:
   - [Status Clock](https://itunes.apple.com/us/app/status-clock/id552792489?mt=12)
   - [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)
   - [Navicat Essentials for PostgreSQL](https://www.navicat.com/download/navicat-essentials) - (key in "Software Licenses" Google Doc)
   - [Navicat Essentials for SQLite](https://www.navicat.com/download/navicat-essentials) - (key in "Software Licenses" Google Doc)
1. Configure:
   - Host name: `sudo scutil --set HostName name-you-want`
   - iTerm
     - [Honukai Theme for iTerm (forked)](https://github.com/bradyholt/honukai-iterm-zsh)
     - In settings, tell iTerm to look at `~/.iterm` for settings
   - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
1. Follow steps in "Usage" section above
