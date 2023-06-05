#-
 - Tasmota PCF8575 I2C driver written in Berry
 - (C) 2023 Eduardo Stern <eduardostern@icloud.com>
 - Based on PCF8575 driver found in micropython-pcf8575
 - May 30 2023 - v1 Initial Release
 - June 1 2023 - v1.1 Added Rule Support on Data Change
 - June 2 2023 - v1.2 Added Result for Separate Ports P0-P7 and P10-P17
 - June 3 2023 - v1.3 Bugfixes for stupid bug on last Refactor (it's not C...) 
                      Reverted to old bitmask change detection code
                      Added on(port) and off(port) 
                      i2c address new set on init() constructor
                      Added toggle(port)
 - June 4 2023 - v1.4 2nd Refactor on bitmask change detection code 
 -#


 class PCF8575 : Driver
  var wire          #- if wire == nil then the module is not initialized -#
  var value
  var i2cAddress
  var lastvalue


  def init(i2cAddress)
    self.i2cAddress = i2cAddress
    self.value=nil
    self.lastvalue=nil
    self.wire = tasmota.wire_scan(self.i2cAddress)
    if self.wire 
      print("I2C: PCF8575 detected on bus "+str(self.wire.bus))
    end
  end

  #- returns a 16 bit mask of the ports (10 to 17 and 0 to 7) -#
  def read()
    if !self.wire return nil end  #- exit if not initialized -#

    var r = self.wire.read(self.i2cAddress,0x00,2)
    
    if r == nil return nil end

    r = 0xFFFF-r

    self.value = ((r & 0xFF00)>>8) | ((r & 0x00FF)<<8)

    if self.value != self.lastvalue
      
      if self.lastvalue == nil 
        self.lastvalue = 0xFFFF-self.value 
      end

      import string
      var msg = string.format("{\"PCF8575\":{\"value\":%i",self.value)
      
      for n:0..7
        if (self.value & 0x01<<n != self.lastvalue & 0x01<<n) 
          msg=msg+string.format(", \"P%i\":%i", n,(self.value & 0x01<<n)>>n) 
        end
      end

      for n:8..15
        if (self.value & 0x01<<n != self.lastvalue & 0x01<<n) 
          msg=msg+string.format(", \"P%i\":%i", n+2,(self.value & 0x01<<n)>>n) 
        end
      end

      msg = msg + "}}"

      self.lastvalue=self.value

      tasmota.publish_result(msg, 'RESULT') #- Required to trigger rules on data change - Tasmota Example Driver Should Have This <eduardostern@icloud.com> -#
    end



    return self.value
  end

  def write(bitmask)
	  
    
    
    bitmask = 0xFFFF-bitmask
	  
	  self.wire._begin_transmission(self.i2cAddress)
	  self.wire._write(bitmask & 0x00FF) 
	  self.wire._write(bitmask >> 8)
	  self.wire._end_transmission()

    return 0xFFFF-bitmask

  end


  def off(port) #- PCF8575 port from 0-7 and 10-17. -#


    if port >= 8 port = port-2 end

    var setbit = 0x01 << port
    
    var bitmask = self.value & (~setbit)
   
	  bitmask = 0xFFFF-bitmask
	  
	  self.wire._begin_transmission(self.i2cAddress)
	  self.wire._write(bitmask & 0x00FF) 
	  self.wire._write(bitmask >> 8)
	  self.wire._end_transmission()
	  #- self.wire.write(self.i2c,0x00,65535-newvalue) -#
    return 0xFFFF-bitmask

  end


  def on(port) #- PCF8575 port from 0-7 and 10-17.  -#


    if port >= 8 port = port-2 end

    var setbit = 0x01 << port
    var bitmask = self.value | setbit
    
	  bitmask = 0xFFFF-bitmask
	  
	  self.wire._begin_transmission(self.i2cAddress)
	  self.wire._write(bitmask & 0x00FF) 
	  self.wire._write(bitmask >> 8)
	  self.wire._end_transmission()
	  #- self.wire.write(self.i2c,0x00,65535-newvalue) -#
    return 0xFFFF-bitmask

  end



  def toggle(port) #- PCF8575 port from 0-7 and 10-17.  -#


    if port >= 8 port = port-2 end

    var setbit = 0x01 << port
    var bitmask = self.value ^ setbit
    
	  bitmask = 0xFFFF-bitmask
	  
	  self.wire._begin_transmission(self.i2cAddress)
	  self.wire._write(bitmask & 0x00FF) 
	  self.wire._write(bitmask >> 8)
	  self.wire._end_transmission()
	  #- self.wire.write(self.i2c,0x00,65535-newvalue) -#
    return 0xFFFF-bitmask

  end




  #- trigger a read every second -#

  def every_250ms()
    if !self.wire return nil end  #- exit if not initialized -#
    self.read()
  end

  #- display sensor value in the web UI -#
  def web_sensor()
    if !self.wire return nil end  #- exit if not initialized -#
    import string
    var msg = string.format(
	     "{s}PCF8575 value{m}%i{e}"..
       "{s}PCF8575 P0{m}%i{e}{s}PCF8575 P1{m}%i{e}{s}PCF8575 P2{m}%i{e}{s}PCF8575 P3{m}%i{e}"..
       "{s}PCF8575 P4{m}%i{e}{s}PCF8575 P5{m}%i{e}{s}PCF8575 P6{m}%i{e}{s}PCF8575 P7{m}%i{e}"..
       "{s}PCF8575 P10{m}%i{e}{s}PCF8575 P11{m}%i{e}{s}PCF8575 P12{m}%i{e}{s}PCF8575 P13{m}%i{e}"..
       "{s}PCF8575 P14{m}%i{e}{s}PCF8575 P15{m}%i{e}{s}PCF8575 P16{m}%i{e}{s}PCF8575 P17{m}%i{e}",
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

		",\"PCF8575\":{\"value\":%i, \"P0\":%i"..
    ", \"P1\":%i, \"P2\":%i, \"P3\":%i, \"P4\":%i, \"P5\":%i, \"P6\":%i, \"P7\":%i"..
    ", \"P10\":%i, \"P11\":%i, \"P12\":%i, \"P13\":%i, \"P14\":%i, \"P15\":%i, \"P16\":%i, \"P17\":%i}",

              self.value, 
              (self.value & 0x01)>>0

              ,(self.value & 0x02)>>1,(self.value & 0x04)>>2,(self.value & 0x08)>>3,

              (self.value & 0x10)>>4,(self.value & 0x20)>>5,(self.value & 0x40)>>6,(self.value & 0x80)>>7,

              (self.value & 0x100)>>8,(self.value & 0x200)>>9,(self.value & 0x400)>>10,(self.value & 0x800)>>11,

              (self.value & 0x1000)>>12,(self.value & 0x2000)>>13,(self.value & 0x4000)>>14,(self.value & 0x8000)>>15

            
            
            
            
            
            )

    tasmota.response_append(msg)
  end

end
pcf8575 = PCF8575(0x20)

tasmota.add_driver(pcf8575)
