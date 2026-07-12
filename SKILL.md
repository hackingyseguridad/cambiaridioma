---
name: inicio-kali
description: >
  Usar esta skill SIEMPRE que el usuario acabe de instalar Kali Linux (o cualquier Debian) y quiera
  hacer la configuración inicial / post-instalación del sistema. Activar cuando se mencionen: post
  instalación de Kali, configurar idioma español, poner el teclado en español, cambiar locale a
  es_ES, configurar DNS manual / resolv.conf, instalar y habilitar sshd al arrancar, instalar Google
  Chrome en Debian/Kali, quitar el protector de pantalla / salvapantallas, evitar que se apague la
  pantalla o se suspenda el equipo, cambiar la fuente de la consola en modo texto (Terminus), arrancar
  Kali en modo consola sin entorno gráfico (desactivar X), o crear un USB de arranque para instalar
  Kali Linux. También activar cuando el usuario proporcione una VM o máquina recién instalada y pida
  "dejarla lista" / "script de arranque inicial" / "primeros pasos tras instalar Kali".
  Repositorio de referencia: https://github.com/hackingyseguridad/inicio
---

# Inicio Kali Skill — hackingyseguridad/inicio

Skill de configuración inicial (post-instalación) de Kali Linux / Debian. Cubre idioma y teclado en
español, DNS manual, SSH persistente, navegador, fuente de consola, gestión de energía/pantalla,
modo consola sin X, y creación del USB de instalación. Todos los scripts están pensados para
ejecutarse como `root` (o con `sudo`) justo después de instalar el sistema.

---

## FASE 0 — Preparación del entorno

```bash
git clone https://github.com/hackingyseguridad/inicio
cd inicio
chmod +x *.sh

# Comprobar que se ejecuta como root (la mayoría de scripts lo requieren)
[ "$(id -u)" -eq 0 ] || echo "Aviso: ejecutar con sudo/root"
```

| Script / fichero | Función |
|---|---|
| `instalar.sh` | Teclado + idioma del sistema en español |
| `keyboard`, `locale` | Plantillas copiadas a `/etc/default/` por `instalar.sh` |
| `resolv.sh` | DNS manual fijo en `/etc/resolv.conf` (inmutable) |
| `instalarssh.sh` | Instala y habilita el servicio SSH al arrancar |
| `installchrome.sh` | Instala Google Chrome estable |
| `tipoletra.sh` | Fuente de consola Terminus (modo texto, sin X) |
| `noapagarpantalla.sh` | Desactiva salvapantallas/DPMS (consola + XFCE4) |
| `noapagarpantalla2.sh` | Igual que el anterior + persistencia, suspensión/hibernación, discos (hdparm) y autoarranque por usuario |
| `deactivaX.sh` | Arranca el sistema en modo consola (sin entorno gráfico) |
| `usbinstalacion.sh` | Crea un USB de arranque para instalar Kali Linux |

---

## FASE 1 — Idioma y teclado en español

Usa `instalar.sh`: pone el teclado en distribución `es` (con `sundeadkeys`), fija el locale del
sistema a `es_ES.UTF-8` (idioma y formato de hora), y copia las plantillas `keyboard` y `locale`
a `/etc/default/`. También da permisos de ejecución a todos los `.sh` del repositorio.

```bash
sudo ./instalar.sh
```

**Verificación:**
```bash
localectl status
cat /etc/default/keyboard
cat /etc/default/locale
```

---

## FASE 2 — DNS manual persistente

Usa `resolv.sh`: sobrescribe `/etc/resolv.conf` con servidores DNS fijos (IPv4/IPv6) y lo bloquea
con `chattr +i` para que ningún proceso (NetworkManager, DHCP, resolvconf) pueda modificarlo.

```bash
sudo ./resolv.sh
```

**Antes de volver a editar `/etc/resolv.conf` manualmente**, hay que quitar el atributo inmutable:
```bash
chattr -i /etc/resolv.conf
```

Para cambiar los servidores DNS por defecto del script, editar la variable `RESOLVER` dentro de
`resolv.sh` antes de ejecutarlo.

---

## FASE 3 — SSH persistente

Usa `instalarssh.sh`: instala el paquete `ssh` (OpenSSH server), arranca el servicio y lo habilita
para que se inicie automáticamente en cada arranque (`update-rc.d` + `systemctl enable`).

```bash
sudo ./instalarssh.sh
```

**Verificación:**
```bash
systemctl status ssh
ss -tlnp | grep :22
```

> Si el objetivo es un hardening completo de sshd (puertos, port knocking, fail2ban, claves, CVE
> regreSSHion, etc.), usar la skill `ssh-pentest` / la guía de bastionado dedicada en lugar de
> quedarse solo con esta instalación básica.

---

## FASE 4 — Fuente de consola (modo texto)

Usa `tipoletra.sh`: instala las fuentes Terminus y configura de forma no interactiva la consola en
modo texto (sin X) con la fuente **Terminus Bold 12x24**, evitando el asistente de
`dpkg-reconfigure console-setup`.

```bash
sudo ./tipoletra.sh
```

Útil especialmente en servidores/VMs sin entorno gráfico o en modo consola tras usar
`deactivaX.sh`.

---

## FASE 5 — Navegador (Google Chrome)

Usa `installchrome.sh`: descarga el `.deb` oficial de Google Chrome estable y lo instala con `apt`.

```bash
sudo ./installchrome.sh
```

**Ejecución** (desde consola, con usuario no root, recomendado en Kali por diseño):
```bash
google-chrome-stable --no-sandbox --user-data-dir
```

---

## FASE 6 — Gestión de energía y pantalla

Dos niveles de agresividad según necesidad:

| Necesidad | Script recomendado |
|---|---|
| Solo desactivar salvapantallas/DPMS de la sesión gráfica actual (no persiste tras reinicio) | `noapagarpantalla.sh` |
| Persistencia completa: sin apagado de pantalla, sin suspensión/hibernación, sin apagado de discos, con autoarranque por usuario en cada login | `noapagarpantalla2.sh` |

```bash
# Opción rápida, no persistente
sudo ./noapagarpantalla.sh

# Opción completa y persistente (recomendada para servidores/labs siempre encendidos)
sudo ./noapagarpantalla2.sh
```

`noapagarpantalla2.sh` detecta automáticamente al usuario de la sesión gráfica activa y le instala
una entrada en `~/.config/autostart/` para reaplicar la configuración en cada login. También admite
invocación directa del modo usuario (lo hace el propio autoarranque, no hace falta lanzarlo a mano):
```bash
bash noapagarpantalla2.sh --user-only
```

---

## FASE 7 — Modo consola sin entorno gráfico (opcional)

Usa `deactivaX.sh`: cambia el target por defecto de systemd a `multi-user.target`, de forma que el
sistema arranque siempre en modo consola (CLI) sin entorno gráfico.

```bash
sudo ./deactivaX.sh
```

**Revertir** (volver a arrancar en modo gráfico):
```bash
sudo systemctl set-default graphical.target
```

---

## FASE 8 — Crear USB de instalación de Kali (antes de instalar)

Usa `usbinstalacion.sh` **desde otra máquina ya instalada**, para preparar el pendrive de
instalación de Kali Linux.

```bash
lsblk                     # IMPRESCINDIBLE: identificar el dispositivo correcto antes de continuar
sudo dd if=kali-linux-2025.4-installer-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

> ⚠️ El script trae por defecto `/dev/sdb` como destino. **Nunca ejecutar sin comprobar antes con
> `lsblk`** cuál es el dispositivo real del USB: un error de dispositivo (p. ej. apuntar al disco
> del sistema) provoca pérdida de datos irreversible.

---

## FASE 9 — Decisión: qué ejecutar según el escenario

| Escenario | Scripts a ejecutar |
|---|---|
| Estación de trabajo de pentesting (uso diario, entorno gráfico) | `instalar.sh`, `resolv.sh`, `instalarssh.sh`, `installchrome.sh`, `noapagarpantalla2.sh` |
| Servidor / VM headless (sin entorno gráfico) | `instalar.sh`, `resolv.sh`, `instalarssh.sh`, `tipoletra.sh`, `deactivaX.sh` |
| Laboratorio siempre encendido (evitar cortes por suspensión/pantalla) | `noapagarpantalla2.sh` (incluye discos y suspensión, más completo que `noapagarpantalla.sh`) |
| Preparar medio de instalación desde cero | `usbinstalacion.sh` (en máquina externa, antes de instalar Kali) |

---

## ORDEN RECOMENDADO (instalación completa típica)

```bash
git clone https://github.com/hackingyseguridad/inicio
cd inicio
chmod +x *.sh

sudo ./instalar.sh          # 1. Idioma y teclado
sudo ./resolv.sh             # 2. DNS manual
sudo ./instalarssh.sh        # 3. SSH persistente
sudo ./tipoletra.sh          # 4. Fuente de consola
sudo ./noapagarpantalla2.sh  # 5. Sin apagado de pantalla/suspensión (opcional)
sudo ./installchrome.sh      # 6. Navegador (solo si hay entorno gráfico)
sudo ./deactivaX.sh          # 7. Modo consola sin X (opcional, solo servidores)
```

---

## REFERENCIAS

- Repositorio: https://github.com/hackingyseguridad/inicio
- Scripts: `instalar.sh`, `resolv.sh`, `instalarssh.sh`, `installchrome.sh`, `tipoletra.sh`,
  `noapagarpantalla.sh`, `noapagarpantalla2.sh`, `deactivaX.sh`, `usbinstalacion.sh`
- Ficheros de configuración: `keyboard`, `locale`
- www.hackingyseguridad.com
