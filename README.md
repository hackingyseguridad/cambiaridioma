# cambiaridioma

#No persistente

setxkbmap es sundeadkeys

update-locale LANG=es_ES.UTF-8 LANGUAGE

localectl set-locale LANG=es_ES.UTF-8

sudo localectl set-locale LC_TIME=es_ES.UTF-8

sudo localectl set-locale LC_TIME=es_ES.UTF-8

sudo locale-gen es_ES.UTF-8

update-locale LANG=es_ES.UTF-8

#Persistente

vim /etc/default/locale

LANG=es_ES.UTF-8

LC_TIME=es_ES.UTF-8

vim /etc/default/keyboard 

XKBMODEL="pc105"

XKBLAYOUT="es"

XKBVARIANT=""

XKBOPTIONS=""

BACKSPACE="guess"
