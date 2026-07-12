#!/bin/bash
# Simple Script en Bash Shell 1.0.x., desactiva modo x, modo grafico en Kali Linux,  en Linux Debian

echo "Desactiva modo x, modo grafico en Kali Linux"

systemctl set-default multi-user.target
