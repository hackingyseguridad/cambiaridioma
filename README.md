# inicio

Scripts de configuración inicial tras instalar **Kali Linux** (Debian SO). Automatizan tareas repetitivas de post-instalación: idioma, teclado, DNS, SSH, protector de pantalla, navegador y creación del USB de instalación.

## Requisitos previos

- Kali Linux (o cualquier Debian) recién instalado.
- Acceso a una cuenta con privilegios `root` / `sudo`.
- Conexión a Internet (necesaria para `instalar.sh`, `instalarssh.sh` e `installchrome.sh`).

## Estructura del repositorio

| Fichero | Tipo | Descripción |
|---|---|---|
| [`instalar.sh`](instalar.sh) | Script | Configura el teclado a distribución española (`es`, `sundeadkeys`) y el idioma del sistema a `es_ES.UTF-8` (locale y hora). Copia los ficheros `keyboard` y `locale` a `/etc/default/`. Da permisos de ejecución (`chmod 777`) a todos los `.sh` del directorio. |
| [`keyboard`](keyboard) | Fichero de configuración | Plantilla para `/etc/default/keyboard`: modelo `pc105`, distribución `es`. |
| [`locale`](locale) | Fichero de configuración | Plantilla para `/etc/default/locale`: `LANG="es_ES.UTF-8"`. |
| [`deactivaX.sh`](deactivaX.sh) | Script | Desactiva el entorno gráfico (modo X) estableciendo el target por defecto de systemd a `multi-user.target` (arranque en modo consola/CLI). |
| [`resolv.sh`](resolv.sh) | Script | Sobrescribe `/etc/resolv.conf` con servidores DNS personalizados (IPv4/IPv6) y lo bloquea con `chattr +i` para evitar que sea modificado o sobrescrito por otros procesos (p. ej. NetworkManager/DHCP). |
| [`instalarssh.sh`](instalarssh.sh) | Script | Instala el servidor `ssh` (OpenSSH), lo arranca y lo habilita en el inicio del sistema (`update-rc.d` y `systemctl enable`). |
| [`installchrome.sh`](installchrome.sh) | Script | Descarga e instala Google Chrome estable (`.deb`) y muestra cómo lanzarlo desde consola con un usuario no root. |
| [`tipoletra.sh`](tipoletra.sh) | Script | Instala las fuentes Terminus y configura automáticamente la consola en modo texto (sin X) con la fuente **Terminus Bold 12x24**, evitando el asistente interactivo de `dpkg-reconfigure console-setup`. |
| [`noapagarpantalla.sh`](noapagarpantalla.sh) | Script | Desactiva el salvapantallas y el apagado de pantalla (DPMS) en consola y en entorno gráfico XFCE4. Contiene además una versión POSIX (`desactivar-blank-pantalla.sh`) que persiste la configuración en `/etc/rc.local` y en `/etc/kbd/config`, y ajusta `xfce4-power-manager` vía `xfconf-query`. |
| [`noapagarpantalla2.sh`](noapagarpantalla2.sh) | Script | Versión más completa y persistente: bloquea suspensión/hibernación a nivel de `systemd`, ajusta `/etc/systemd/logind.conf`, desactiva el apagado/espera de discos duros (`hdparm`), detecta al usuario de la sesión gráfica y le instala una entrada de autoarranque (`~/.config/autostart`) para reaplicar la configuración en cada login. Soporta el modo `--user-only` para la parte de sesión gráfica. |
| [`usbinstalacion.sh`](usbinstalacion.sh) | Script | Vuelca una ISO de instalación de Kali Linux a un pendrive (`dd`) para crear un USB de arranque. **Requiere editar el dispositivo de destino antes de ejecutarlo.** |

## Orden de uso recomendado

1. **Crear el USB de instalación** (desde otra máquina, antes de instalar Kali): `usbinstalacion.sh`.
2. **Tras la instalación de Kali**, con acceso root:
   ```bash
   chmod +x *.sh
   sudo ./instalar.sh          # Idioma y teclado en español
   sudo ./resolv.sh            # DNS personalizado
   sudo ./instalarssh.sh       # Servidor SSH
   sudo ./tipoletra.sh         # Fuente de consola (modo texto)
   ```
3. **Opcional, según el entorno de uso:**
   ```bash
   sudo ./deactivaX.sh          # Arrancar en modo consola (sin entorno gráfico)
   sudo ./installchrome.sh      # Instalar Google Chrome (entorno gráfico)
   sudo ./noapagarpantalla2.sh  # Evitar apagado de pantalla/suspensión (recomendado, más completo)
   ```

## Advertencias

- **`resolv.sh`** bloquea `/etc/resolv.conf` con el atributo inmutable (`chattr +i`). Si necesitas volver a modificarlo manualmente, ejecuta antes `chattr -i /etc/resolv.conf`.
- **`usbinstalacion.sh`** usa `dd` sobre `/dev/sdb` por defecto: verifica siempre con `lsblk` cuál es el dispositivo correcto antes de ejecutarlo, ya que un error de dispositivo puede provocar pérdida de datos.
- **`deactivaX.sh`** desactiva el arranque en entorno gráfico; revertirlo requiere `systemctl set-default graphical.target`.
- Todos los scripts están pensados para ejecutarse como `root` o con `sudo` en una instalación de Kali Linux/Debian recién instalada.

## Licencia

Sin licencia especificada en el repositorio original. Consulta con el autor antes de reutilizar el código en otros proyectos.



#
http://wwww.hackingyseguridad.com/

Repositorio: [hackingyseguridad/inicio](https://github.com/hackingyseguridad/inicio)
#

