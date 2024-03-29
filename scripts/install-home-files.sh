#!/bin/bash
set -euo pipefail
export DOTFILES_PATH="$HOME/.dotfiles"


# diff $HOME/.bashrc $HOME/.dotfiles/home/.bashrc

ln -sf $HOME/.dotfiles/home/.bashrc $HOME/.bashrc
ln -sf $HOME/.dotfiles/home/.zshrc $HOME/.zshrc
ln -sf $HOME/.dotfiles/home/.vimrc $HOME/.vimrc
ln -sf $HOME/.dotfiles/home/.gitignore_global $HOME/.gitignore_global
ln -sf $HOME/.dotfiles/home/.gitattributes $HOME/.gitattributes
ln -sf $HOME/.dotfiles/home/.zshenv $HOME/.zshenv
ln -sf $HOME/.dotfiles/home/.tmux.conf $HOME/.tmux.conf
ln -sf $HOME/.dotfiles/home/.tmate.conf $HOME/.tmate.conf
ln -sf $HOME/.dotfiles/home/.gitconfig $HOME/.gitconfig


unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    source $DOTFILES_PATH/linux/install-linux-files.sh
elif [[ "$unamestr" == 'Darwin' ]]; then
    source $DOTFILES_PATH/osx/install-osx-files.sh
fi
