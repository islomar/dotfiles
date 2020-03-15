#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl wget git npm htop ctop maven slack postman docker docker-machine
brew cask install virtualbox vagrant google-chrome firefox

# Vundle for vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# To install manually:
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
# Magnet (Windows manager)

# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
