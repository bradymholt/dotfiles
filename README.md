# dotfiles

This is my system configuration for OS X, consisting of config "dotfiles" and shell scripts.

## Usage

- Clone this repo to a directory in the $HOME folder; `cd` to this directory
- Run `./setup.sh` - this will symlink everything in `/home` and call `/other/setup.sh` to setup other config that resides outside of $HOME and/or requires special handling.  It _is_ safe to run this command multiple times and after adding new config files.
- If there are files in $HOME that you would like to be moved to the "dotfiles" configuration, you can run `dotfiles-link.sh` and pass in the name of the file that resides in $HOME.  This will move the file to `/home` and create a symlink to it. 

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
2. Install the shell helpers:
  - [RVM](https://rvm.io/rvm/install)
  - [NVM](https://github.com/creationix/nvm)
3. Install the following apps:
  - [LastPass](https://lastpass.com/)
  - [BetterSnapTool](https://itunes.apple.com/us/app/bettersnaptool/id417375580?mt=12) - Already purchased; install from Mac App Store
  - [Day-O](http://shauninman.com/archive/2011/10/20/day_o_mac_menu_bar_clock)
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
  - Node 4 - `nvm install 4 && nvm use 4`
  - Ruby 2.1.1 - `rvm install 2.1.1 && rvm --default use 2.1.1`
4. Configure:
  - [Honukai Theme for iTerm](https://github.com/oskarkrawczyk/honukai-iterm-zsh/)

## Desktop Screenshot

![desktop screenshot](https://cloud.githubusercontent.com/assets/759811/15767420/60dd2f24-290d-11e6-88c7-301d1aa46813.png "Desktop Screenshot")
