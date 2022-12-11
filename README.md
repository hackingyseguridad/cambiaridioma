# cambiaridioma

sudo dpkg-reconfigure locales
dpkg-reconfigure keyboard-configuration

# No persistente

setxkbmap es sundeadkeys

update-locale LANG=es_ES.UTF-8 LANGUAGE

localectl set-locale LANG=es_ES.UTF-8

sudo localectl set-locale LC_TIME=es_ES.UTF-8

sudo localectl set-locale LC_TIME=es_ES.UTF-8

sudo locale-gen es_ES.UTF-8

update-locale LANG=es_ES.UTF-8

# Persistente

vim /etc/default/locale

LANG=es_US.UTF-8

LANGUAGE="es_ES:es"

LC_ALL="es_ES.UTF-8"


vim /etc/default/keyboard 

XKBMODEL="pc105"

XKBLAYOUT="es"

XKBVARIANT=""

XKBOPTIONS=""

BACKSPACE="guess"

#
Si es un PC portatil con teclado reducido 


XKBMODEL=""

XKBLAYOUT="es"

XKBVARIANT=""

XKBOPTIONS=""

BACKSPACE="guess"


