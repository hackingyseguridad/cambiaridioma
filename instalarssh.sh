#!/bin/bash
echo Script instalar/habilitar sshd y configurar inicio automatico
# reenvio a puerto 2222: socat -d -d TCP-L:22,reuseaddr,fork SYSTEM:"nc \$SOCAT_PEERADDR 22"

sudo apt-get install ssh
sudo service ssh start
sudo update-rc.d ssh enable
sudo systemctl enable ssh.service
