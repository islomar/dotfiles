#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl wget git npm htop ctop maven slack postman tree the_silver_searcher
brew cask install virtualbox vagrant google-chrome firefox skype visual-studio-code spotify skype zoomus slack

# Vundle for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# SDKMan
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

brew cleanup

# TODO: 
#   Install python, go, php
#   Configure zsh
#   Generate GPG key: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
#   Configure aliases
#     https://gist.github.com/tyomo4ka/f76ac325ecaa3260808b98e715410067
#     alias brewery='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
#     IntelliJ
#     cdgo
#     cdw
#     ll
#     alias cleanup-docker="docker stop (docker ps -qa) && docker rm (docker ps -qa) && docker system prune -f && docker volume prune -f"


# To install manually:
#   Docker Desktop:   https://hub.docker.com/editions/community/docker-ce-desktop-mac
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
#   Notion:           https://www.notion.so/desktop
#   Grammarly
# Magnet (Windows manager)

# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
#   Connect GitHub with SSH: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   Enable Find My Mac: https://support.apple.com/en-gb/guide/findmy-mac/fmm53101237/mac
