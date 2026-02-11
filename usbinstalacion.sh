

# crear un USB de arranque para instalar Kali Linux desde Pendrive
sudo dd if=kali-linux-2025.4-installer-amd64.iso of=/dev/sdb bs=4M status=progress conv=fsync
