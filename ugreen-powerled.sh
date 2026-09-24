#!/bin/sh
# UGREEN DXP480T Plus - power LED fix for Arc Loader / Xpenology (DSM 7.x)
#
# Sets the front power LED to solid white when DSM boots.
# On the DXP480T Plus the LED controller sits on the SMBus I801 adapter at
# address 0x26 (not 0x3a like the rest of the DXP range), so the Arc
# "ledcontrol" addon cannot find it.
#
# Install: copy to /usr/local/etc/rc.d/ugreen-powerled.sh and chmod 755.

# Find the SMBus I801 bus number (bus 0 on the tested unit)
BUS=$(for d in /sys/bus/i2c/devices/i2c-*; do grep -q "SMBus I801" $d/name 2>/dev/null && basename $d | cut -d- -f2; done | head -1)
[ -z "$BUS" ] && BUS=0

solid() {
  /usr/sbin/i2cset -y $BUS 0x26 0xa0 1 b   # red off
  /usr/sbin/i2cset -y $BUS 0x26 0xa0 2 b   # white off
  /usr/sbin/i2cset -y $BUS 0x26 0x51 0 b   # slow flash off
  /usr/sbin/i2cset -y $BUS 0x26 0xb1 2 b   # white on
  /usr/sbin/i2cset -y $BUS 0x26 0x50 0 b   # solid (fast flash off)
}

case "$1" in
  start) solid; sleep 5; solid ;;
  stop) ;;
esac
exit 0
