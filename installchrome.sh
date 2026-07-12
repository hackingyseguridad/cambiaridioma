#!/bin/bash
# Simple Script en Bash Shell 1.0.x., para instalar y ejecutar el navegador Web Google Chrome en Linux Debian

# Instalacion:
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

# Elecutar
echo 
echo "ejecutar desde consola y desde un usuario no root .."
echo
google-chrome-stable --no-sandbox --user-data-dir

