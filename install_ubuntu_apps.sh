#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# TO DO
# dpkg -l <packageName>

mkdir -p ~/bin
mkdir -p ~/tmp
cd ~
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install gimp telegram-desktop snapd fzf tree tldr jq vim tmux tmate curl git npm yarn maven gitk git-gui silversearcher-ag htop ctop virtualbox vagrant xclip gnome-shell-pomodoro php-cli php-zip php-mbstring unzip xournal xboxdrv git-extras -y
sudo snap install postman
sudo snap install emote
sudo snap install slack --classic
sudo snap install helm --classic
sudo apt-get install smartmontools -y
sudo apt-get install --no-install-recommends gnome-panel -y

# microk8s (alternative to minikube)
sudo snap install microk8s --classic
sudo usermod -a -G microk8s islomar
mkdir -p ~/.kube
sudo chown -f -R islomar ~/.kube
newgrp microk8s

# Ubuntu themes
sudo apt install gnome-tweaks -y
sudo apt install adwaita-icon-theme-full -y
sudo apt install arc-theme -y
sudo apt install numix-gtk-theme numix-icon-theme -y

curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash

curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Vundle for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# Oh my zsh
sudo apt-get install zsh fonts-powerline -y
sudo chsh -s /bin/zsh $USER
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "source ${HOME}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
source ${HOME}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
cd ~/.oh-my-zsh/custom/plugins && git clone https://github.com/matthieusb/zsh-sdkman.git && cd -
# And after that, you have to log out from the current user and log in again
helm completion zsh > "${fpath[1]}/_helm"


# Python
curl https://pyenv.run | bash
pyenv install 3.10
# Configure Python with zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# brew & pyenv
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Adobe
wget ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb
sudo dpkg -i AdbeRdr9.5.5-1_i386linux_enu.deb
# Install missing dependencies
sudo apt install -f -y
rm AdbeRdr9.5.5-1_i386linux_enu.deb

# Dropbox
sudo apt install libpango1.0-0
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd

# Spotify
sudo snap install spotify

# Docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce
sudo systemctl status docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# SDKMan
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Git
git config --global user.name "Isidro Lopez"
git config --global user.email "islomar@gmail.com"
git config --global core.editor vim
git config --global commit.gpgsign true

# Samba (sharing folders)
# https://www.how2shout.com/linux/how-to-install-samba-on-ubuntu-22-04-lts-jammy-linux/
sudo apt install samba -y
sudo systemctl enable --now smbd
sudo ufw allow samba
sudo usermod -aG sambashare $USER
sudo smbpasswd -a $USER

# Visual Studio Code
# sudo snap install --classic code
# sudo apt-get install apt-transport-https
# sudo snap install code

# Chrome
cd ~/tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
cd -

# bat: https://github.com/sharkdp/bat
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

sudo apt autoremove --purge -y
sudo apt autoclean

# Manual steps
## Generate GPG key: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
## Dropbox: set up the automatic boot (if you want it) https://linoxide.com/linux-how-to/install-dropbox-ubuntu/
