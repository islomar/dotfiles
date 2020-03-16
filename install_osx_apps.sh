#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl wget git npm htop ctop maven slack tree the_silver_searcher fzf
brew cask install postman virtualbox vagrant google-chrome firefox skype visual-studio-code spotify skype zoomus slack iterm2 sourcetree

# Vundle for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# SDKMan
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew tap homebrew/cask-fonts
brew cask install font-awesome-terminal-fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd .. && rm -rf fonts

brew cleanup

# TODO: 
#   Install python, go, php
#   Generate GPG key: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
#   Configure aliases
#     https://gist.github.com/tyomo4ka/f76ac325ecaa3260808b98e715410067
#     alias brewery='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
#     IntelliJ
#     cdgo
#     alias cleanup-docker="docker stop (docker ps -qa) && docker rm (docker ps -qa) && docker system prune -f && docker volume prune -f"


# To install manually:
#   Docker Desktop:   https://hub.docker.com/editions/community/docker-ce-desktop-mac
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
#   Notion:           https://www.notion.so/desktop
#   Grammarly


# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
#   In the Terminal, configure the font size and the Powerline font that you want, e.g. Powerline-patched Meslo
#   Connect GitHub with SSH: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   Enable Find My Mac: https://support.apple.com/en-gb/guide/findmy-mac/fmm53101237/mac
