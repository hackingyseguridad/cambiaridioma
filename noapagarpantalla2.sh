#!/bin/bash

#!/bin/bash

set -e

# =======================================================================
# MODO "--user-only": SOLO la parte de sesion grafica (X/XFCE).
# Este modo lo invoca el propio autoarranque; no hace falta lanzarlo a mano.
# =======================================================================
if [ "$1" = "--user-only" ]; then

    echo ">> [usuario] Desactivando salvapantallas y DPMS a nivel de X..."
    xset s off     2>/dev/null || true
    xset s noblank 2>/dev/null || true
    xset -dpms     2>/dev/null || true

    xfconf_set() {
        canal="$1"; propiedad="$2"; tipo="$3"; valor="$4"
        if xfconf-query -c "$canal" -p "$propiedad" >/dev/null 2>&1; then
            xfconf-query -c "$canal" -p "$propiedad" -s "$valor" 2>/dev/null || true
        else
            xfconf-query -c "$canal" -p "$propiedad" -n -t "$tipo" -s "$valor" 2>/dev/null || true
        fi
    }

    if command -v xfconf-query >/dev/null 2>&1; then
        echo ">> [usuario] Configurando xfce4-power-manager..."
        xfconf_set xfce4-power-manager /xfce4-power-manager/blank-on-ac int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/blank-on-battery int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/dpms-enabled bool false
        xfconf_set xfce4-power-manager /xfce4-power-manager/dpms-on-ac-off int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/dpms-on-ac-sleep int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/dpms-on-battery-off int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/dpms-on-battery-sleep int 0
        xfconf_set xfce4-power-manager /xfce4-power-manager/lock-screen-suspend-hibernate bool false
        xfconf_set xfce4-power-manager /xfce4-power-manager/logind-handle-lid-switch bool false
    fi

    echo ">> [usuario] Cerrando procesos de bloqueo de pantalla si estan activos..."
    killall xscreensaver      2>/dev/null || true
    killall light-locker      2>/dev/null || true
    killall xfce4-screensaver 2>/dev/null || true

    exit 0
fi

# =======================================================================
# MODO PRINCIPAL: requiere root. Cambios de sistema + instalacion del
# autoarranque para el usuario grafico.
# =======================================================================
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root: sudo bash $0" >&2
    exit 1
fi

SCRIPT_PATH="$(readlink -f "$0")"

echo "== 1. Bloqueando suspension e hibernacion a nivel de systemd =="
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true

echo "== 2. Configurando /etc/systemd/logind.conf =="
LOGIND_CONF="/etc/systemd/logind.conf"
set_logind() {
    clave="$1"; valor="$2"
    if grep -q "^${clave}=" "$LOGIND_CONF" 2>/dev/null; then
        sed -i "s/^${clave}=.*/${clave}=${valor}/" "$LOGIND_CONF"
    elif grep -q "^#${clave}=" "$LOGIND_CONF" 2>/dev/null; then
        sed -i "s/^#${clave}=.*/${clave}=${valor}/" "$LOGIND_CONF"
    else
        echo "${clave}=${valor}" >> "$LOGIND_CONF"
    fi
}
set_logind HandleLidSwitch ignore
set_logind HandleLidSwitchExternalPower ignore
set_logind HandleLidSwitchDocked ignore
set_logind HandleSuspendKey ignore
set_logind HandleHibernateKey ignore
set_logind IdleAction ignore
systemctl restart systemd-logind 2>/dev/null || true

echo "== 3. Desactivando el apagado/espera de los discos duros (hdparm) =="
if command -v hdparm >/dev/null 2>&1; then
    for disco in /sys/block/sd*; do
        [ -e "$disco" ] || continue
        nombre="$(basename "$disco")"
        rota="$(cat "$disco/queue/rotational" 2>/dev/null || echo 1)"
        if [ "$rota" = "1" ]; then
            hdparm -S 0 -B 255 "/dev/${nombre}" >/dev/null 2>&1 || true
            echo "  - /dev/${nombre}: spindown/APM desactivado."
        fi
    done
else
    echo "  - Aviso: hdparm no esta instalado, se omite este paso (apt install hdparm)." >&2
fi

echo "== 4. Persistiendo la configuracion de discos entre reinicios (/etc/rc.local) =="
RC_LOCAL="/etc/rc.local"
LINEA_HDPARM='for d in /sys/block/sd*; do [ -e "$d" ] && hdparm -S 0 -B 255 "/dev/$(basename $d)" >/dev/null 2>&1; done'

if [ ! -f "$RC_LOCAL" ]; then
    printf '#!/bin/sh -e\n\nexit 0\n' > "$RC_LOCAL"
fi
chmod +x "$RC_LOCAL"

if ! grep -qF "hdparm -S 0 -B 255" "$RC_LOCAL" 2>/dev/null; then
    TMP_FILE="${RC_LOCAL}.tmp.$$"
    awk -v linea="$LINEA_HDPARM" '
        /^exit 0/ && !done { print linea; done=1 }
        { print }
    ' "$RC_LOCAL" > "$TMP_FILE"
    mv "$TMP_FILE" "$RC_LOCAL"
    chmod +x "$RC_LOCAL"
fi

echo "== 5. Detectando usuario de la sesion grafica =="
TARGET_USER="${SUDO_USER:-}"
if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    TARGET_USER="$(loginctl list-sessions --no-legend 2>/dev/null | awk '$4=="seat0"{print $3; exit}')"
fi
if [ -z "$TARGET_USER" ]; then
    TARGET_USER="$(who | awk '{print $1; exit}')"
fi

if [ -z "$TARGET_USER" ]; then
    echo "  - Aviso: no se ha detectado un usuario con sesion grafica activa." >&2
    echo "  - Los cambios de sistema ya estan aplicados. Ejecuta manualmente dentro" >&2
    echo "    de la sesion grafica: bash $SCRIPT_PATH --user-only" >&2
else
    echo "  - Usuario grafico detectado: ${TARGET_USER}"
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
    TARGET_GROUP="$(id -gn "$TARGET_USER" 2>/dev/null || echo "$TARGET_USER")"

    echo "== 6. Instalando autoarranque para reaplicar en cada login =="
    AUTOSTART_DIR="${TARGET_HOME}/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    cat > "${AUTOSTART_DIR}/noapagarpantalla.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=No apagar pantalla
Exec=bash ${SCRIPT_PATH} --user-only
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

    echo "== 7. Deshabilitando el autoarranque de bloqueadores de pantalla =="
    for LOCKER in light-locker.desktop xfce4-screensaver.desktop xscreensaver.desktop; do
        if [ -f "/etc/xdg/autostart/${LOCKER}" ]; then
            cat > "${AUTOSTART_DIR}/${LOCKER}" <<EOF
[Desktop Entry]
Hidden=true
EOF
        fi
    done
    chown -R "${TARGET_USER}:${TARGET_GROUP}" "$AUTOSTART_DIR"

    echo "== 8. Aplicando ya mismo la configuracion de sesion grafica =="
    DISPLAY_VAR=":0"
    XAUTH_FILE="${TARGET_HOME}/.Xauthority"
    sudo -u "$TARGET_USER" DISPLAY="$DISPLAY_VAR" XAUTHORITY="$XAUTH_FILE" \
        bash "$SCRIPT_PATH" --user-only || \
        echo "  - Aviso: no se pudo aplicar en caliente (¿sesion X activa ahora mismo?). Se aplicara en el proximo login." >&2
fi

echo "== Proceso completado: pantalla, protector, DPMS, suspension,"
echo "   hibernacion y espera de discos quedan desactivados de forma"
echo "   persistente y sin intervencion manual. =="
exit 0


