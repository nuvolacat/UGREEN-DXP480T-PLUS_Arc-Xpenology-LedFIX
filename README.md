# UGREEN DXP480T Plus — Arc / Xpenology LED fix

Script que deja **fijo en blanco el LED de encendido** de un **UGREEN DXP480T Plus** con DSM (Xpenology) arrancado mediante **Arc Loader**.

> 🇬🇧 English summary at the end.

## El problema

Con un sistema que no es UGOS, el LED de encendido del DXP480T Plus se queda **parpadeando para siempre**. En UGOS es el propio sistema quien le dice al controlador de LEDs que el arranque ha terminado. DSM no lo hace.

Arc incluye un addon, `ledcontrol`, para los LEDs de UGREEN, pero **en este modelo no hace nada**:

| Modelo | Controlador de LEDs (SMBus I801) |
|---|---|
| DXP2800 / 4800 / 6800 / 8800 y otros | dirección `0x3a` ← la que usa el addon `ledcontrol` |
| **DXP480T Plus** | dirección **`0x26`** ← la que usa este script |

El addon busca el chip en `0x3a`, no lo encuentra (`power: unavailable or non-existent`) y el LED sigue parpadeando.

## Qué hace el script

Al arrancar DSM envía por I²C al controlador `0x26` esta secuencia:

| Registro | Valor | Efecto |
|---|---|---|
| `0xa0` | `1` / `2` | apaga el rojo / apaga el blanco |
| `0x51` | `0` | desactiva el parpadeo lento |
| `0xb1` | `2` | enciende el blanco |
| `0x50` | `0` | modo fijo (sin parpadeo rápido) |

Detecta automáticamente el número de bus del adaptador `SMBus I801` (en el equipo probado es el bus `0`). Repite la secuencia a los 5 segundos por si algún servicio del arranque la pisa.

Solo usa `i2cset`, que ya viene con DSM. No instala nada más ni toca el loader.

## Compatibilidad

| | |
|---|---|
| Equipo | UGREEN **DXP480T Plus** |
| Loader | **Arc 4.1.0b5** — probado |
| DSM | 7.4.1 (modelo SA6400) — probado |

Puede funcionar con otras versiones de Arc o de DSM, pero **no está probado**. Con otros modelos UGREEN **no funcionará**: usan la dirección `0x3a` y para esos ya está el addon `ledcontrol` de Arc.

## Limitación: el parpadeo durante el arranque

Desde que pulsas el botón hasta que DSM termina de arrancar, el LED **seguirá parpadeando**. Ese parpadeo lo controla el firmware del equipo y ningún sistema operativo puede cambiarlo antes de haberse cargado; con UGOS pasa lo mismo. El script lo deja fijo en cuanto DSM arranca, así que el LED fijo indica que el NAS ya está listo.

## Instalación

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

## Desinstalación

```sh
sudo rm /usr/local/etc/rc.d/ugreen-powerled.sh
```

En el siguiente arranque el LED volverá a parpadear como antes.

## Créditos

Los registros del controlador `0x26` salen de lo que publicaron usuarios del DXP480T Plus en el [foro de IPv64](https://v64.tech/t/ugreen-dxp-480t-plus-blinkende-led/4293). El resto de la gama DXP está documentada en [miskcoo/ugreen_leds_controller](https://github.com/miskcoo/ugreen_leds_controller).

## Aviso

Se entrega tal cual, sin garantía (licencia MIT). Escribe en el bus I²C del equipo: úsalo solo en un DXP480T Plus.

---

## 🇬🇧 English summary

Makes the **power LED solid white** on a **UGREEN DXP480T Plus** running DSM through **Arc Loader** (tested with **Arc 4.1.0b5** and DSM 7.4.1; other versions may work but are **untested**).

The Arc `ledcontrol` addon does nothing on this model because it looks for the LED controller at `0x3a`. On the DXP480T Plus the controller is at **`0x26`** on the SMBus I801 adapter.

Install (needs **SSH** access as an admin user):

```sh
sudo -i
curl -fsSL -o /usr/local/etc/rc.d/ugreen-powerled.sh \
  https://raw.githubusercontent.com/nuvolacat/UGREEN-DXP480T-PLUS_Arc-Xpenology-LedFIX/main/ugreen-powerled.sh
chmod 755 /usr/local/etc/rc.d/ugreen-powerled.sh
/usr/local/etc/rc.d/ugreen-powerled.sh start
```

The LED still blinks from power-on until DSM has booted. That part is handled by the firmware and no OS can change it.
