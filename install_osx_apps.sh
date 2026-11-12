#!/bin/bash
# Apps to install on Mac OSX

set -x
set -e

cd ~/tmp

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

brew doctor
brew update

brew install mas tfenv tealdeer vim tmux tmate curl wget git htop ctop maven tree the_silver_searcher fzf eza bat gpg autojump pipenv composer lazygit watch cloc watchman graphviz git-extras rumdl vale shellcheck jq
brew install --cask terraform-linters/tap/tflint
vale sync --config ~/.dotfiles/config/vale/.vale.ini
brew install --cask postman virtualbox vagrant google-chrome firefox visual-studio-code spotify zoom slack iterm2 sourcetree gpg-suite rectangle rocket vlc

# Node.js through nvm, as on Linux. nvm doesn't support its Homebrew formula.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
source "$NVM_DIR/nvm.sh"
nvm install --lts
# Node 25 and later no longer bundle corepack, which provides yarn and pnpm.
npm install -g corepack
corepack enable

# Vundle for vim
wget https://raw.githubusercontent.com/islomar/dotfiles/master/.vimrc && cp -pr .vimrc "$HOME/"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# SDKMan
curl -s "https://get.sdkman.io" | bash
# shellcheck source=/dev/null
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Font Fira Code
brew install --cask font-fira-code

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install --cask font-awesome-terminal-fonts
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts && ./install.sh && cd .. && rm -rf fonts
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash

brew cleanup


# To install manually:
#   Docker Desktop:   https://hub.docker.com/editions/community/docker-ce-desktop-mac
#   IntelliJ Toolbox: https://www.jetbrains.com/toolbox-app/download/#section=mac
#   Notion:           https://www.notion.so/desktop
#   Grammarly
#   Add plugins to .zshrc: zsh-autosuggestions zsh-syntax-highlightning
#   Python: https://swapps.com/blog/how-to-configure-virtualenvwrapper-with-python3-in-osx-mojave/
#     * pipenv: https://docs.python-guide.org/dev/virtualenvs/#installing-pipenv
#   Authy: https://authy.com
#   Oh My Zsh - Fix Agnoster theme:
#     https://github.com/agnoster/agnoster-zsh-theme/issues/72
#     Use the Solarized theme: https://www.freecodecamp.org/news/jazz-up-your-bash-terminal-a-step-by-step-guide-with-pictures-80267554cb22/


# Other configurations:
#   Turn on FileVault (it requires an Apple ID)
#   Turn on Firewall
#   In the Terminal, configure the font size and the Powerline font that you want, e.g. Powerline-patched Meslo
#   Generate and configure a new GPG: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
#   Connect GitHub with SSH: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
#   Enable Find My Mac: https://support.apple.com/en-gb/guide/findmy-mac/fmm53101237/mac
#   https://github.com/CodelyTV/dotfiles/blob/master/doc/installation-guide.md
#     Contexts (Windows Switcher): https://contexts.co/
#     Authy
#     Monosnap (screenshots)
#     Caret (Markdown editor)
#     Rocket (emojis)
#     Magnet (Windows Manager, like Spectacle)
#     Bartender (menu bar icons manager): https://www.macbartender.com/
# https://www.genbeta.com/mac/mejor-software-gratuito-para-instalar-tu-nuevo-mac


# TO DO
#   * VPN: ProtonVPN, Windscribe...
