#!/bin/bash
set -euo pipefail

DOTFILES_FOLDER=$HOME/.dotfiles
echo DOTFILES_FOLDER=$DOTFILES_FOLDER

# diff $HOME/.bashrc $HOME/.dotfiles/home/.bashrc

ln -sf $HOME/.dotfiles/home/.bashrc $HOME/.bashrc
ln -sf $HOME/.dotfiles/home/.zshrc $HOME/.zshrc
ln -sf $HOME/.dotfiles/home/.vimrc $HOME/.vimrc
ln -sf $HOME/.dotfiles/home/.gitignore_global $HOME/.gitignore_global
ln -sf $HOME/.dotfiles/home/.gitattributes $HOME/.gitattributes
ln -sf $HOME/.dotfiles/home/.zsenv $HOME/.zsenv
#ln -sf $HOME/.dotfiles/home/.gitconfig $HOME/.gitconfig

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    source $DOTFILES_FOLDER/linux/install-linux-files.sh
elif [[ "$unamestr" == 'Darwin' ]]; then
    source $DOTFILES_FOLDER/osx/install-osx-files.sh
fi