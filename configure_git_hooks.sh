#!/bin/bash

cp -pr ./hooks/* ~/workspace/$1/.git/hooks/
cd ~/workspace/$1/.git/hooks && chmod +x pre-push