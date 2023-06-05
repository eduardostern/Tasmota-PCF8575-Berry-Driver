# Tasmota-PCF8575-Berry-Driver

PCF8575 Module Driver for ESP32 MCU running Tasmota Written in Berry
(c) 2023 Eduardo Stern <eduardostern@icloud.com>

The code can be loaded manually with copy/paste on the Berry Scripting Console, or stored in flash and loaded at startup in autoexec.be as load("pcf8575.be"). Alternatively it can be loaded with a Tasmota native command or rule:

Br load("pcf8575.be")

Default is to find PCF8575 at i2c address 0x20. You can change the constructor to other address.

Functions:

read() - Returns a 16bit mask with the ports P0-P7 and P10-P17
write(bitmask) - Writes a 16bit mask with the ports P0-P7 and P10-P17
on(port) - Set port to on state
off(port) - Set port to off state
toggle(port) - Toggle port state


When the driver detects a change on any of the PCF8575, it triggers the rule system with value as bitmask and P0-P7 and P10-P17 only when changed as 0 or 1:

tele/tasmota_X/RESULT = {"PCF8575":{"value":0, "P0":0, "P1":0, "P2":0, "P3":0, "P4":0, "P5":0, "P6":0, "P7":0, "P10":0, "P11":0, "P12":0, "P13":0, "P14":0, "P15":0, "P16":0, "P17":0}}


Example Rule:

Rule1 ON PCF8575#P0 DO LedPower1 %value% ENDON
Rule1 1



