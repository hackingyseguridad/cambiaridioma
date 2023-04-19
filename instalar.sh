#!/usr/bin/env bash
echo 
echo "Instalando ... "
setxkbmap es sundeadkeys
update-locale LANG=es_ES.UTF-8 
localectl set-locale LANG=es_ES.UTF-8
localectl set-locale LC_TIME=es_ES.UTF-8
localectl set-locale LC_TIME=es_ES.UTF-8
locale-gen es_ES.UTF-8
cp keyboard /etc/default/
cp locale /etc/default/
echo "ñ"
echo "configurado el teclado a ES ! "
echo 
