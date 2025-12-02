
# Sin salvapantalla, siempre activa!
 setvesablank 0

 # desde modo X  Xfce4

xset s off
xset -dpms
xset s noblank
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
