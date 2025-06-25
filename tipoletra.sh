

# Para automatizar la configuración de la fuente de la consola (Terminus Bold 12x24) en Kali Linux (modo texto, sin X), evitando el menú interactivo de dpkg-reconfigure console-setup,

apt-get  install -y fonts-terminus console-terminus

sudo bash -c 'cat > /etc/default/console-setup <<EOF
# Configuración automática para Terminus Bold 12x24
ACTIVE_CONSOLES="/dev/tty[1-6]"
CHARMAP="UTF-8"
CODESET="guess"
FONTFACE="Terminus"
FONTSIZE="12x24"
FONT="ter-124b"
EOF'
