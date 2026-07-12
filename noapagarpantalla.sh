
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

#!/bin/sh
# desactivar-blank-pantalla.sh
# Automatiza la desactivacion del blanking/powerdown de pantalla
# (consola y entorno grafico XFCE) sin intervencion manual.
# Compatible POSIX / shell antiguo: sin [[ ]], sin bashismos.
#
# Uso: sudo sh desactivar-blank-pantalla.sh

set -e

RC_LOCAL="/etc/rc.local"
KBD_CONFIG="/etc/kbd/config"
LINEA_SETTERM="setterm -blank 0 -powerdown 0"

# --- Comprobacion de privilegios ---
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root (sudo)." >&2
    exit 1
fi

echo "== 1. Configurando ${RC_LOCAL} =="

if [ ! -f "$RC_LOCAL" ]; then
    printf '#!/bin/sh -e\n\nexit 0\n' > "$RC_LOCAL"
    chmod +x "$RC_LOCAL"
fi

if grep -qF "$LINEA_SETTERM" "$RC_LOCAL" 2>/dev/null; then
    echo "  - La linea setterm ya existe, no se duplica."
else
    if grep -q '^exit 0' "$RC_LOCAL"; then
        # Inserta antes de "exit 0" para no romper el script
        TMP_FILE="${RC_LOCAL}.tmp.$$"
        awk -v linea="$LINEA_SETTERM" '
            /^exit 0/ && !done { print linea; done=1 }
            { print }
        ' "$RC_LOCAL" > "$TMP_FILE"
        mv "$TMP_FILE" "$RC_LOCAL"
    else
        echo "$LINEA_SETTERM" >> "$RC_LOCAL"
    fi
    echo "  - Linea anadida correctamente."
fi

chmod +x "$RC_LOCAL"

echo "== 2. Contenido actual de ${RC_LOCAL} =="
cat "$RC_LOCAL"

echo "== 3. Configurando ${KBD_CONFIG} (blanking de consola) =="

if [ -f "$KBD_CONFIG" ]; then
    if grep -q '^BLANK_TIME=' "$KBD_CONFIG"; then
        sed -i 's/^BLANK_TIME=.*/BLANK_TIME=0/' "$KBD_CONFIG"
    else
        echo "BLANK_TIME=0" >> "$KBD_CONFIG"
    fi

    if grep -q '^POWERDOWN_TIME=' "$KBD_CONFIG"; then
        sed -i 's/^POWERDOWN_TIME=.*/POWERDOWN_TIME=0/' "$KBD_CONFIG"
    else
        echo "POWERDOWN_TIME=0" >> "$KBD_CONFIG"
    fi
    echo "  - BLANK_TIME y POWERDOWN_TIME fijados a 0."
else
    echo "  - Aviso: ${KBD_CONFIG} no existe, se omite este paso." >&2
fi

echo "== 4. Comprobando entorno de escritorio =="
echo "  - XDG_CURRENT_DESKTOP actual: ${XDG_CURRENT_DESKTOP:-no definido (sesion sin GUI activa)}"

echo "== 5. Configurando xfce4-power-manager via xfconf-query =="

DISPLAY_VAR="${DISPLAY:-:0}"
export DISPLAY="$DISPLAY_VAR"

if command -v xfconf-query >/dev/null 2>&1; then
    # -n -t <tipo> -s <valor> crea la propiedad si no existe, sin preguntar nada
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -n -t int -s 0 2>/dev/null \
        || xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0

    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -n -t int -s 0 2>/dev/null \
        || xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0

    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -n -t bool -s false 2>/dev/null || true

    echo "  - Propiedades xfce4-power-manager aplicadas."
else
    echo "  - Aviso: xfconf-query no disponible en este contexto (sin sesion XFCE activa). Se omite este paso." >&2
fi

echo "== Proceso completado sin intervencion manual =="
exit 0
