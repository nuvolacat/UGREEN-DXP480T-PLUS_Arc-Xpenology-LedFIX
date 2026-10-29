<div align="center">

# UGREEN DXP480T Plus — Arc / Xpenology LED fix

**LED de encendido fijo en blanco con DSM · Solid white power LED on DSM**

Script para el **UGREEN DXP480T Plus** con DSM (Xpenology) arrancado mediante **Arc Loader**.<br>
Script for the **UGREEN DXP480T Plus** running DSM (Xpenology) through **Arc Loader**.

![UGREEN DXP480T Plus](https://img.shields.io/badge/UGREEN-DXP480T%20Plus-00a0e9)
![Arc 4.1.0b5](https://img.shields.io/badge/Arc%20Loader-4.1.0b5%20probado%20%2F%20tested-5d4fb3)
![DSM 7.4.1](https://img.shields.io/badge/DSM-7.4.1%20SA6400-1f6feb)
![POSIX sh](https://img.shields.io/badge/sh-i2cset-4eaa25?logo=gnubash&logoColor=white)
![I²C 0x26](https://img.shields.io/badge/I%C2%B2C-SMBus%20I801%20%400x26-5a5a5a)
![MIT](https://img.shields.io/badge/licencia%20%2F%20license-MIT-3c8d5a)

**[Castellano](#-castellano)** · **[English](#-english)**

</div>

---

## 🇪🇸 Castellano

Script que deja **fijo en blanco el LED de encendido** de un **UGREEN DXP480T Plus** con DSM (Xpenology) arrancado mediante **Arc Loader**.

### 🔦 El problema

Con un sistema que no es UGOS, el LED de encendido del DXP480T Plus se queda **parpadeando para siempre**. En UGOS es el propio sistema quien le dice al controlador de LEDs que el arranque ha terminado. DSM no lo hace.

Arc incluye un addon, `ledcontrol`, para los LEDs de UGREEN, pero **en este modelo no hace nada**:

| Modelo | Controlador de LEDs (SMBus I801) |
|---|---|
| DXP2800 / 4800 / 6800 / 8800 y otros | dirección `0x3a` ← la que usa el addon `ledcontrol` |
| **DXP480T Plus** | dirección **`0x26`** ← la que usa este script |

El addon busca el chip en `0x3a`, no lo encuentra (`power: unavailable or non-existent`) y el LED sigue parpadeando.

### ⚙️ Qué hace el script

Al arrancar DSM envía por I²C al controlador `0x26` esta secuencia:

| Registro | Valor | Efecto |
|---|---|---|
| `0xa0` | `1` / `2` | apaga el rojo / apaga el blanco |
| `0x51` | `0` | desactiva el parpadeo lento |
| `0xb1` | `2` | enciende el blanco |
| `0x50` | `0` | modo fijo (sin parpadeo rápido) |

Detecta automáticamente el número de bus del adaptador `SMBus I801` (en el equipo probado es el bus `0`). Repite la secuencia a los 5 segundos por si algún servicio del arranque la pisa.

Solo usa `i2cset`, que ya viene con DSM. No instala nada más ni toca el loader.

### ✅ Compatibilidad

| | |
|---|---|
| Equipo | UGREEN **DXP480T Plus** |
| Loader | **Arc 4.1.0b5** — probado |
| DSM | 7.4.1 (modelo SA6400) — probado |

Puede funcionar con otras versiones de Arc o de DSM, pero **no está probado**. Con otros modelos UGREEN **no funcionará**: usan la dirección `0x3a` y para esos ya está el addon `ledcontrol` de Arc.

### ⏳ Limitación: el parpadeo durante el arranque

Desde que pulsas el botón hasta que DSM termina de arrancar, el LED **seguirá parpadeando**. Ese parpadeo lo controla el firmware del equipo y ningún sistema operativo puede cambiarlo antes de haberse cargado; con UGOS pasa lo mismo. El script lo deja fijo en cuanto DSM arranca, así que el LED fijo indica que el NAS ya está listo.

### 📦 Instalación

Hace falta **entrar al NAS por SSH** con un usuario administrador.

1. En DSM, activa SSH: **Panel de control → Terminal y SNMP → Habilitar servicio SSH**.
2. Conéctate desde tu ordenador:
   ```sh
   ssh TU_USUARIO@IP_DEL_NAS
   ```
3. Pasa a root:
   ```sh
   sudo -i
   ```
4. Comprueba que el controlador está en `0x26` (debe devolver un valor, no `Error`):
   ```sh
   i2cget -y 0 0x26 0x50 b
   ```
5. Instala el script:
   ```sh
   mkdir -p /usr/local/etc/rc.d
   curl -fsSL -o /usr/local/etc/rc.d/ugreen-powerled.sh \
     https://raw.githubusercontent.com/nuvolacat/UGREEN-DXP480T-PLUS_Arc-Xpenology-LedFIX/main/ugreen-powerled.sh
   chmod 755 /usr/local/etc/rc.d/ugreen-powerled.sh
   ```
6. Aplícalo sin reiniciar:
   ```sh
   /usr/local/etc/rc.d/ugreen-powerled.sh start
   ```
   El LED debería quedarse fijo en blanco al momento.
7. (Opcional) Vuelve a desactivar SSH en el Panel de control.

DSM ejecuta automáticamente los scripts de `/usr/local/etc/rc.d/` en cada arranque, y esa carpeta se conserva al actualizar DSM.

Si tienes activado el addon `ledcontrol` en Arc, puedes desactivarlo: en este modelo no hace nada.

### 🧹 Desinstalación

```sh
sudo rm /usr/local/etc/rc.d/ugreen-powerled.sh
```

En el siguiente arranque el LED volverá a parpadear como antes.

### 🙌 Créditos

Los registros del controlador `0x26` salen de lo que publicaron usuarios del DXP480T Plus en el [foro de IPv64](https://v64.tech/t/ugreen-dxp-480t-plus-blinkende-led/4293). El resto de la gama DXP está documentada en [miskcoo/ugreen_leds_controller](https://github.com/miskcoo/ugreen_leds_controller).

### ⚠️ Aviso

Se entrega tal cual, sin garantía (licencia MIT). Escribe en el bus I²C del equipo: úsalo solo en un DXP480T Plus.

---

## 🇬🇧 English

Script that makes the **power LED solid white** on a **UGREEN DXP480T Plus** running DSM (Xpenology) through **Arc Loader**.

### 🔦 The problem

On anything other than UGOS, the DXP480T Plus power LED **keeps blinking forever**. On UGOS the system itself tells the LED
controller that boot has finished. DSM does not.

Arc ships an addon, `ledcontrol`, for UGREEN LEDs, but **it does nothing on this model**:

| Model | LED controller (SMBus I801) |
|---|---|
| DXP2800 / 4800 / 6800 / 8800 and others | address `0x3a` ← used by the `ledcontrol` addon |
| **DXP480T Plus** | address **`0x26`** ← used by this script |

The addon looks for the chip at `0x3a`, does not find it (`power: unavailable or non-existent`) and the LED keeps blinking.

### ⚙️ What the script does

When DSM boots it sends this sequence over I²C to controller `0x26`:

| Register | Value | Effect |
|---|---|---|
| `0xa0` | `1` / `2` | red off / white off |
| `0x51` | `0` | slow blink off |
| `0xb1` | `2` | white on |
| `0x50` | `0` | solid mode (fast blink off) |

It detects the `SMBus I801` bus number automatically (bus `0` on the tested unit) and repeats the sequence after 5 seconds
in case a boot service overrides it. It only uses `i2cset`, which ships with DSM. It installs nothing else and does not
touch the loader.

### ✅ Compatibility

| | |
|---|---|
| Device | UGREEN **DXP480T Plus** |
| Loader | **Arc 4.1.0b5** — tested |
| DSM | 7.4.1 (SA6400 model) — tested |

It may work with other Arc or DSM versions, but that is **untested**. It will **not** work on other UGREEN models: they use
address `0x3a`, and Arc's `ledcontrol` addon already covers them.

### ⏳ Limitation: blinking during boot

From power-on until DSM has finished booting the LED **keeps blinking**. That part is handled by the device firmware and no
OS can change it before it has loaded; UGOS behaves the same. The script makes it solid as soon as DSM is up, so a solid
LED means the NAS is ready.

### 📦 Installation

You need **SSH access** to the NAS with an administrator account.

1. In DSM, enable SSH: **Control Panel → Terminal & SNMP → Enable SSH service**.
2. Connect from your computer:
   ```sh
   ssh YOUR_USER@NAS_IP
   ```
3. Become root:
   ```sh
   sudo -i
   ```
4. Check that the controller answers at `0x26` (it must return a value, not `Error`):
   ```sh
   i2cget -y 0 0x26 0x50 b
   ```
5. Install the script:
   ```sh
   mkdir -p /usr/local/etc/rc.d
   curl -fsSL -o /usr/local/etc/rc.d/ugreen-powerled.sh \
     https://raw.githubusercontent.com/nuvolacat/UGREEN-DXP480T-PLUS_Arc-Xpenology-LedFIX/main/ugreen-powerled.sh
   chmod 755 /usr/local/etc/rc.d/ugreen-powerled.sh
   ```
6. Apply it without rebooting:
   ```sh
   /usr/local/etc/rc.d/ugreen-powerled.sh start
   ```
   The LED should turn solid white right away.
7. (Optional) Disable SSH again in the Control Panel.

DSM runs the scripts in `/usr/local/etc/rc.d/` on every boot, and that folder survives DSM updates. If Arc's `ledcontrol`
addon is enabled you can disable it: it does nothing on this model.

### 🧹 Uninstall

```sh
sudo rm /usr/local/etc/rc.d/ugreen-powerled.sh
```

The LED will blink again from the next boot.

### 🙌 Credits

The `0x26` controller registers come from what DXP480T Plus owners posted on the
[IPv64 forum](https://v64.tech/t/ugreen-dxp-480t-plus-blinkende-led/4293). The rest of the DXP range is documented in
[miskcoo/ugreen_leds_controller](https://github.com/miskcoo/ugreen_leds_controller).

### ⚠️ Disclaimer

Provided as is, without warranty (MIT license). It writes to the device's I²C bus: use it only on a DXP480T Plus.

---

<div align="center">
<br>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/readme/nuvola-oscuro.png">
  <img src="docs/readme/nuvola-claro.png" width="160" alt="nuvola">
</picture>

© NUVOLACAT
</div>
