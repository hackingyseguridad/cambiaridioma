
#!/bin/bash

# desacticar protector de salvapantallas desde modo X  Xfce4
sleep 1; xset s off
sleep 1; xset s noblank
sleep 1; xset s noexpose
sleep 1; xset -dpms
xset s off
xset q

# Sin salvapantalla, siempre activa!
 setvesablank 0

# Quitar xscreensaver (si está instalado)
sudo apt remove xscreensaver

# O para light-locker
sudo apt remove light-locker

#

sudo sh -c 'echo "setterm -blank 0 -powerdown 0" >> /etc/rc.local'
cat /etc/rc.local

vim /etc/kbd/config
echo $XDG_CURRENT_DESKTOP
export DISPLAY=:0\nxfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0\nxfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
