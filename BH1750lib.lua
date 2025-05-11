-- 100 T1ak --date= 2025-05-11 08:55:18

-- Configuration
i2c_id = 0
bh1750_address = 0x23
--sda_pin = 21 -- Replace with your SDA pin
--scl_pin = 22 -- Replace with your SCL pin

-- BH1750 Commands (High Resolution Mode)
local BH1750_CONTINUOUS_HIGH_RES = 0x01
local BH1750_ONE_TIME_HIGH_RES = 0x10
local Continuous_Low_Resolution_Mode = 0x13
--[[
Power Down 0000_0000 No active state.
Power On 0000_0001 Waiting for measurement command.
Reset 0000_0111 Reset Data register value. Reset command is not acceptable in
Power Down mode.
Continuously H-Resolution Mode 0001_0000 0x10  1lx 120ms
Continuously H-Resolution Mode2 0001_0001 0x11 0.5lx 120ms.
Continuously L-Resolution Mode 0001_0011 0x13 4lx 16ms.
One Time H-Resolution Mode 0010_0000 0x20
One Time H-Resolution Mode2 0010_0001 0x21
One Time L-Resolution Mode 0010_0011 0x23
Change Measurement time
( High bit ) 01000_MT[7,6,5] Change measurement time.
※ Please refer "adjust measurement result for influence of optical window."
Change Masurement time
( Low bit ) 011_MT[4,3,2,1,0] Change measurement time.
※ Please refer "adjust measurement result for influence of optical window."
]]
-- Initialize I2C
--i2c.setup(i2c_id, sda_pin, scl_pin, i2c.SLOW)

function BH1750init(kod1,kod2)
   i2c.start(i2c_id)
   i2c.address(i2c_id, bh1750_address, i2c.TRANSMITTER)
   i2c.write(i2c_id, kod1,false)
   i2c.write(i2c_id, kod2,false)
   i2c.stop(i2c_id)
  end
  
-- Function to read raw data (2 bytes)
local function read_raw_light()
  i2c.start(i2c_id)
  i2c.address(i2c_id, bh1750_address, i2c.RECEIVER)
  local msb = i2c.read(i2c_id, 2)
  i2c.stop(i2c_id)
  return msb --string.byte(msb, 1) * 256 + string.byte(lsb, 1)
end

-- Function to get light level in Lux
function get_lux(kod)
  if kod==nil then print(' 10,11,13,20,21,23 ') end
  i2c.start(i2c_id)
  i2c.address(i2c_id, bh1750_address, i2c.TRANSMITTER)
  i2c.write(i2c_id, kod ,false)
  i2c.stop(i2c_id)

  -- Wait for measurement (adjust as needed - datasheet usually specifies time)
  --tmr.delay(200) -- 180 ms is typical for high resolution
  
  local raw_value = read_raw_light()
  if raw_value then
    return raw_value:byte(1)*256 + raw_value:byte(2) -- / 1.2 -- Conversion factor for high resolution
  else
    return nil
  end
end

-- Example usage
BH1750init(0x01,0x07)
--[[local lux_value = get_lux(0x23)
if lux_value then
  print("Light level: " .. string.format("%.5d", lux_value) .. " Lux")
else
  print("Error reading light level")
end
]]
