#!/bin/bash

# Asegurarnos de que el script se ejecuta en el entorno gráfico correcto
export DISPLAY=:0

echo ">> Desactivando protector de pantalla a nivel de X Server..."
# Desactivar screensaver y blanking a nivel de X11
xset s off         # Desactiva el salvapantallas
xset s noblank     # Evita que la pantalla se ponga en negro
xset -dpms         # Desactiva el ahorro de energía (Energy Star)

echo ">> Configurando Xfce4 Power Manager..."
# Desactivar el apagado de pantalla en XFCE (cuando está enchufado a la corriente)
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
# Desactivar DPMS en XFCE
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
# Opcional: Desactivar también si está con batería
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-sleep -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-battery-off -s 0

echo ">> Matando procesos de bloqueo si están corriendo..."
# En lugar de desinstalarlos con apt (que es destructivo), simplemente los cerramos
killall xscreensaver 2>/dev/null
killall light-locker 2>/dev/null

echo ">> Estado actual de Xset:"
xset q | grep -E "DPMS|timeout"

echo ">> ¡Listo! La pantalla no debería apagarse ni bloquearse."
