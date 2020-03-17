#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install vim tmux tmate curl wget git npm htop ctop maven slack tree the_silver_searcher fzf exa bat gpg autojump
brew cask install postman virtualbox vagrant google-chrome firefox skype visual-studio-code spotify skype zoomus slack iterm2 sourcetree gpg-suite

# Vundle for vim
wget https://raw.githubusercontent.com/islomar/dotfiles/master/.vimrc && cp -pr .vimrc $HOME/
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
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


brew cleanup

# TODO: 
#   Install python, php
#   https://github.com/CodelyTV/dotfiles/blob/master/doc/installation-guide.md

# To install manually:
#   Docker Desktop:   https://hub.docker.com/editions/community/docker-ce-desktop-mac
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
#   Notion:           https://www.notion.so/desktop
#   Grammarly
#   Add plugins to .zshrc: zsh-autosuggestions zsh-syntax-highlightning
#   Python: https://swapps.com/blog/how-to-configure-virtualenvwrapper-with-python3-in-osx-mojave/

# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
#   In the Terminal, configure the font size and the Powerline font that you want, e.g. Powerline-patched Meslo
#   Generate and configure a new GPG: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
#   Connect GitHub with SSH: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   Enable Find My Mac: https://support.apple.com/en-gb/guide/findmy-mac/fmm53101237/mac
