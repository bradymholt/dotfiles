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

When setting up an OS X system initially, the following steps should be performed to get a base system setup.  **NOTE:** These steps should be performed before running `./setup.sh`
 
1. Install [Homebrew](http://brew.sh/) and then `brew install` the following packages:
  - git
  - lame
  - mysql
  - node
  - postgresql
  - wget
  - imagemagick
  - gawk
  - vim
2. Install the shell helpers:
  - [RVM](https://rvm.io/rvm/install)
  - [NVM](https://github.com/creationix/nvm)
3. Install the following apps:
  - [LastPass](https://lastpass.com/)
  - [BetterSnapTool](https://itunes.apple.com/us/app/bettersnaptool/id417375580?mt=12) - Already purchased; install from Mac App Store
  - [FinderPath](https://bahoom.com/finderpath/)
  - [Itsycal](https://www.mowglii.com/itsycal/)
  - [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)
  - Xcode Command Line Tools - `xcode-select --install`
  - [iTerm2](https://www.iterm2.com/downloads.html)
  - [Zsh and Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH)
  - [VS Code](https://code.visualstudio.com/docs?dv=osx)
  - [Beyond Compare 4](http://www.scootersoftware.com/download.php) - Activation key in LastPass
  - [Navicat Essentials for PostgreSQL](https://www.navicat.com/download/navicat-essentials) - Activation key in LastPass
  - [Navicat Essentials for SQLite](https://www.navicat.com/download/navicat-essentials) - Activation key in LastPass
  - [LICEcap](http://www.cockos.com/licecap/)
  - [MySQL Workbench](https://www.mysql.com/products/workbench/)
  - [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  - [Android Studio](https://developer.android.com/studio/index.html)
  - [CloudApp](https://www.getcloudapp.com/)
  - Node 4 - `nvm install 4 && nvm use 4`
  - Ruby 2.1.1 - `rvm install 2.1.1 && rvm --default use 2.1.1`
4. Configure:
  - [Honukai Theme for iTerm](https://github.com/bradyholt/honukai-iterm-zsh)
    - iTerm font: https://github.com/powerline/fonts/blob/master/Meslo/Meslo%20LG%20M%20DZ%20Regular%20for%20Powerline.otf
  - Screenshots Folder
    - `mkdir ~/Screenshots`
    - `defaults write com.apple.screencapture location ~/Screenshots/`
    - `killall SystemUIServer`
