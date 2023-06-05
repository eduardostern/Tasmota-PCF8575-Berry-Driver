# Tasmota-PCF8575-Berry-Driver

Tasmota PCF8575 Module Driver for ESP32 MCU written in Berry

(c) 2023 Eduardo Stern <<eduardostern@icloud.com>>

The code can be loaded manually with copy/paste on the Berry Scripting Console, or stored in flash and loaded at startup in autoexec.be as `load("pcf8575.be")`. Alternatively it can be loaded with a Tasmota native command or rule:

`Br load("pcf8575.be")
`

Default is to find PCF8575 at i2c address 0x20. You can change the constructor to other address.

Functions:

**pcf8575.read()** - Returns a 16bit mask with the ports P0-P7 and P10-P17
**pcf8575.write(bitmask)** - Writes a 16bit mask with the ports P0-P7 and P10-P17
**pcf8575.on(port)** - Set port to on state
**pcf8575.off(port)** - Set port to off state
**pcf8575.toggle(port)** - Toggle port state


When the driver detects a change on any of the PCF8575 ports, it triggers the rule system with **value** as a 16bit bitmask with all the ports and **P0-P7** and **P10-P17** as 0 or 1 when they have their stated changed.:

    tele/tasmota_X/RESULT = {"PCF8575":{"value":0, "P0":0, "P1":0, "P2":0, "P3":0, "P4":0, "P5":0, "P6":0, "P7":0, "P10":0, "P11":0, "P12":0, "P13":0, "P14":0, "P15":0, "P16":0, "P17":0}}

    tele/tasmota_X/RESULT = {"PCF8575":{"value":1, "P0":1}}

Example Rule:

`Rule1 ON PCF8575#P0 DO LedPower1 %value% ENDON`

`Rule1 1`



