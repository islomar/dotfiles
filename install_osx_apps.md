#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl git npm htop ctop maven slack postman
brew cask install virtualbox vagrant

# To install manually: vagrant virtualbox
# Magnet (Windows manager)
