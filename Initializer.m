PortString ="/dev/tty.usbserial-023F1FCE";
BoardType = 'ESP32-WROOM-DevKitC';
esp32 = arduino(PortString, BoardType);
m5core = addon(esp32,'M5Stack/M5Unified');
np = addon(esp32, 'Adafruit/NeoPixel', 'D25', 10, 'NeoPixelType', 'GRB'); 
i2cAddress = '0x58'; % SGP30 default I2C address
