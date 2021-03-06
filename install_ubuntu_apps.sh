#!/bin/bash
set -x
set -e

# TO DO
# dpkg -l <packageName>

cd ~
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install tree tldr jq vim tmux tmate curl git npm yarn maven gitk git-gui silversearcher-ag htop ctop virtualbox vagrant xclip gnome-shell-pomodoro php-cli php-zip php-mbstring unzip xournal xboxdrv git-extras -y
sudo snap install postman
sudo snap install slack --classic
sudo apt-get install smartmontools -y
sudo apt-get install --no-install-recommends gnome-panel -y

# Ubuntu themes
sudo apt install gnome-tweaks -y
sudo apt install adwaita-icon-theme-full -y
sudo apt install arc-theme -y
sudo apt install numix-gtk-theme numix-icon-theme -y

wget -O - https://github.com/nagygergo/jetbrains-toolbox-install/blob/master/jetbrains-toolbox.sh | bash

curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Vundle for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cd ~ && vim +PluginInstall +qall && cd -

# Oh my zsh
sudo apt-get install fonts-powerline -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"

# PHP Installer (https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-18-04)
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Install Golang: https://www.digitalocean.com/community/tutorials/how-to-install-go-on-ubuntu-18-04
## Check the last release: https://golang.org/dl/
cd ~
curl -O https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
tar xvf go1.10.3.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
rm https://dl.google.com/go/go1.13.8.linux-amd64.tar.gz
cd -
# Set Go Paths manually (PATH and GOPATH) in ~/.profile
echo "export GOPATH=$HOME/go" >> ~/.zshrc
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.zshrc

# Python
sudo apt-get install libmysqlclient-dev libpq-dev python-dev -y
sudo apt install python3-pip python-pip -y
pip3 install virtualenv
mkdir ~/.virtualenvs
pip3 install virtualenvwrapper
export WORKON_HOME=~/.virtualenvs
#Finally, copy at the end of .bashrc
#export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
#export WORKON_HOME=$HOME/.virtualenvs
#export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
#source $HOME/.local/bin/virtualenvwrapper.sh

# Adobe
wget ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb
sudo dpkg -i AdbeRdr9.5.5-1_i386linux_enu.deb
# Install missing dependencies
sudo apt install -f -y
rm AdbeRdr9.5.5-1_i386linux_enu.deb

# Dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
# ~/.dropbox-dist/dropboxd

# Spotify
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4773BD5E130D1D45
sudo add-apt-repository "deb http://repository.spotify.com stable non-free"
sudo apt install spotify-client -y

# Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce docker-compose -y
sudo usermod -aG docker islomar

# SDKMan
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Git
git config --global user.name "Isidro Lopez"
git config --global user.email "islomar@gmail.com"
git config --global core.editor vim
git config --global commit.gpgsign true

# Visual Studio Code
sudo snap install --classic code
sudo apt-get install apt-transport-https
sudo snap install code

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

sudo apt autoremove --purge -y
sudo apt autoclean

# Manual steps
## Generate GPG key: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key
## Dropbox: set up the automatic boot (if you want it) https://linoxide.com/linux-how-to/install-dropbox-ubuntu/
