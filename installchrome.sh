#!/bin/bash


wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

echo "ejecutar desde consola y desde un usuario no root "

google-chrome-stable --no-sandbox --user-data-dir

