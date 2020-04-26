#!/bin/bash
set -x
set -e

# diff $HOME/.bashrc $HOME/.dotfiles/home/.bashrc

ln -s $HOME/.dotfiles/.bashrc $HOME/.bashrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/.vimrc $HOME/.vimrc
ln -s $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
ln -s $HOME/.dotfiles/.gitattributes $HOME/.gitattributes
#ln -s $HOME/.dotfiles/.zsenv $HOME/.zsenv