#!/usr/bin/env bash
echo 
echo "Instalando ... "
setxkbmap es sundeadkeys
update-locale LANG=es_ES.UTF-8 LANGUAGE
localectl set-locale LANG=es_ES.UTF-8
sudo localectl set-locale LC_TIME=es_ES.UTF-8
sudo localectl set-locale LC_TIME=es_ES.UTF-8
sudo locale-gen es_ES.UTF-8
update-locale LANG=es_ES.UTF-8
cp keyboard /etc/default/
cp locale /etc/default/
echo "#"
echo "configurado a ES!"
echo 
