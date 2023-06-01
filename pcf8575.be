#-
 - Tasmota PCF8575 I2C driver written in Berry
 - (C) 2023 Eduardo Stern <eduardostern@icloud.com>
 - Based on PCF8575 driver found in micropython-pcf8575
 - May 30 2023 - v1 Initial Release
 - June 1 2023 - v1.1 Added Rule Support on Data Change
 -#


class PCF8575 : Driver
  var wire          #- if wire == nil then the module is not initialized -#
  var value
  var i2c
  var lastvalue


  def init()
    self.i2c = 0x20
    self.value=nil
    self.lastvalue=nil
    self.wire = tasmota.wire_scan(self.i2c)
    if self.wire 
      print("I2C: PCF8575 detected on bus "+str(self.wire.bus))
    end
  end

  #- returns a 16 bit mask of the ports (10 to 17 and 0 to 7) -#
  def read_bitmask()
    if !self.wire return nil end  #- exit if not initialized -#

    
    var r = self.wire.read(self.i2c,0x00,2)
    
    if !r return nil end

    r = 65535-r

    var a = r & 0xFF00
    var b = r & 0x00FF

    self.lastvalue=self.value

    self.value = a>>8 | b<<8

    if self.value != self.lastvalue
      log("PCF8575 BITMASKK VALUE: "+str(self.value))
      import string
      var msg = string.format(
  
      "{\"PCF8575\":{\"value\":%i}}",
  

                self.value)


      tasmota.publish_rule(msg) #- Required to trigger rules on data change - Tasmota Example Driver Should Have This <eduardostern@icloud.com> -#
    end

    return self.value
  end

  def write(bitmask)
	  bitmask = ~bitmask
	  
	  self.wire._begin_transmission(self.i2c)
	  self.wire._write(bitmask & 0x00FF) 
	  self.wire._write(bitmask >> 8)
	  self.wire._end_transmission()
	  #- self.wire.write(self.i2c,0x00,65535-newvalue) -#
  end

  #- trigger a read every second -#

  def every_second()
    if !self.wire return nil end  #- exit if not initialized -#
    self.read_bitmask()
  end

  #- display sensor value in the web UI -#
  def web_sensor()
    if !self.wire return nil end  #- exit if not initialized -#
    import string
    var msg = string.format(
	     "{s}PCF8575 value{m}%i{e}{s}PCF8575 bitmask{m}[%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i]{e}",
	      self.value,
              (self.value & 0x01)>>0,(self.value & 0x02)>>1,(self.value & 0x04)>>2,(self.value & 0x08)>>3,

              (self.value & 0x10)>>4,(self.value & 0x20)>>5,(self.value & 0x40)>>6,(self.value & 0x80)>>7,

              (self.value & 0x100)>>8,(self.value & 0x200)>>9,(self.value & 0x400)>>10,(self.value & 0x800)>>11,

              (self.value & 0x1000)>>12,(self.value & 0x2000)>>13,(self.value & 0x4000)>>14,(self.value & 0x8000)>>15

		)
    tasmota.web_send_decimal(msg)
  end

  #- add sensor value to teleperiod -#

  def json_append()
    if !self.wire return nil end  #- exit if not initialized -#
    import string
    var msg = string.format(

		",\"PCF8575\":{\"value\":%i}",

              self.value)
    tasmota.response_append(msg)
  end

end
pcf8575 = PCF8575()

tasmota.add_driver(pcf8575)
