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

1. Install Homebrew - `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
2. Install apps: `brew install git wget zsh bash vim jq node yarn heroku/brew/heroku postgres && brew tap caskroom/fonts && brew cask install font-meslo-lg iterm2 github google-chrome visual-studio-code phantomjs phantomjs slack itsycal docker beyond-compare spectacle franz db-browser-for-sqlite`
1. Open Chrome and install [1Password X](https://chrome.google.com/webstore/detail/1password-x-%E2%80%93-password-ma/aeblfdkhhhdcdjpifhhbdiojplfjncoa?hl=en) Chrome Extension and login
1. Find `id_rsa` file in 1Password and download to .ssh/id_rsa then run `chmod 600 ~/.ssh/id_rsa`
1. Install:
   - [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) - `sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`
   - [RVM](https://rvm.io/rvm/install) - `\curl -sSL https://get.rvm.io | bash`
   - [Status Clock](https://itunes.apple.com/us/app/status-clock/id552792489?mt=12)
   - [Monosnap](https://://itunes.apple.com/ru/app/monosnap/id540348655)
   - [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)
   - [Driver for AX88179 - USB3.0 to 10/100/1000M Gigabit Ethernet Controller](http://www.asix.com.tw/products.php?op=pItemdetail&PItemID=131;71;112)
1. Configure:
   - Host name: `sudo scutil --set HostName name-you-want`
   - Tell iTerm2 to look at `~/.iterm` for settings
1. Follow steps in "Usage" section above
