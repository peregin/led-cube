// *****************************************
// Led Cube 4x4x4
// Code using 3 x 74HC595 Shift Registers
// 2013.11.27 Levente Fall (info@peregin.com)
// *****************************************

// pin connected to ST_CP of 74HC595
const int latchPin = 10;
// pin connected to SH_CP of 74HC595
const int clockPin = 9;
// pin connected to DS of 74HC595
const int dataPin = 8;
// PIR pin connected to the motion sensor
const int pirPin = 4;

// number of elements should be multipe of 8, representing a frame in the animation
// each pair of bytes controls a layer
byte frames[] = {
  136, 136, 136, 136, 136, 136, 136, 136,
   68,  68,  68,  68,  68,  68,  68,  68,
   34,  34,  34,  34,  34,  34,  34,  34,
   17,  17,  17,  17,  17,  17,  17,  17,
  136, 136,  68,  68,  34,  34,  17,  17,
  255, 255,   0,   0,   0,   0,   0,   0,
    0,   0, 255, 255,   0,   0,   0,   0,
    0,   0,   0,   0, 255, 255,   0,   0,
    0,   0,   0,   0,   0,   0, 255, 255,
    0,   0,   0,   0,   0,   0, 240, 255,
    0,   0,   0,   0,   0,   0,   0, 255,
    0,   0,   0,   0,   0,   0,   0, 240,
    0,   0,   0,   0,   0,  15,   0,   0,
    0,   0, 240,   0,   0,   0,   0,   0,
   15,   0,   0,   0,   0,   0,   0,   0
};

byte allOn[] = {255, 255, 255, 255, 255, 255, 255, 255};


void setup() {
  // set pins to output so you can control the shift register
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  pinMode(pirPin, INPUT);
}

void loop() {
  //loop the data array forever
  int n = sizeof(frames)/sizeof(byte);
  for (int i = 0; i < n; i += 8) {
    if (digitalRead(pirPin) == HIGH) {
      showFrame(allOn);
    } else {
      showFrame(&frames[i]);
    }
  }
}

// an array of 8 bytes, 2 bytes for each layer
// multiplex between the 4 layers
void showFrame(byte *frame) {
  for(int t = 0; t < 20; t++) { // multiplex until a giben amount of time
    for (int k = 0; k < 4; k++) { // turn on/off the 4 layers
      byte* p1 = frame+(k*2);
      byte* p2 = p1++;
      byte layer = 1 << k; 
      showLayer(*p1, *p2, layer);
      delay(3);
    }
  }
}

void showLayer(byte a, byte b, byte layer) {
  // take the latchPin low so  the LEDs don't change while sending in bits:
  digitalWrite(latchPin, LOW);
  
  // shift out the bits:
  shiftOut(dataPin, clockPin, MSBFIRST, a);  
  shiftOut(dataPin, clockPin, MSBFIRST, b);
  shiftOut(dataPin, clockPin, MSBFIRST, layer); // layers 1-2-4-8
  
  //take the latch pin high so the LEDs will light up:
  digitalWrite(latchPin, HIGH);
}
