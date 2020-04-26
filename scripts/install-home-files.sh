#!/bin/bash
set -euo pipefail

DOTFILES_FOLDER=$HOME/.dotfiles
echo DOTFILES_FOLDER=$DOTFILES_FOLDER

# diff $HOME/.bashrc $HOME/.dotfiles/home/.bashrc

ln -sf $HOME/.dotfiles/.bashrc $HOME/.bashrc
ln -sf $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -sf $HOME/.dotfiles/.vimrc $HOME/.vimrc
ln -sf $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
ln -sf $HOME/.dotfiles/.gitattributes $HOME/.gitattributes
ln -sf $HOME/.dotfiles/.zsenv $HOME/.zsenv
#ln -sf $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    source $DOTFILES_FOLDER/linux/install-linux-files.sh
elif [[ "$unamestr" == 'Mac OS X' ]]; then
    source $DOTFILES_FOLDER/osx/install-osx-files.sh
fi