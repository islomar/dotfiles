#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl wget git npm htop ctop maven slack postman docker docker-machine
brew cask install virtualbox vagrant google-chrome firefox skype

# Vundle for vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# To install manually:
*   Docker Desktop:   https://hub.docker.com/editions/community/docker-ce-desktop-mac
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
#   Notion:           https://www.notion.so/desktop
#   Grammarly
# Magnet (Windows manager)

# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
#   Enable Find My Mac: https://support.apple.com/en-gb/guide/findmy-mac/fmm53101237/mac
