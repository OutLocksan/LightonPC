#include <FastLED.h>

// ===========================
// CONFIG (edit these values)
// ===========================
#define LED_PIN       6
#define LED_COUNT     60
#define BRIGHTNESS    180
#define LED_TYPE      WS2812B
#define COLOR_ORDER   GRB
#define SERIAL_BAUD   9600

// ===========================
// END CONFIG
// ===========================

CRGB leds[LED_COUNT];
String incoming;

void setup() {
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, LED_COUNT);
  FastLED.setBrightness(BRIGHTNESS);

  clearStrip();
  Serial.begin(SERIAL_BAUD);
}

void loop() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();

    if (c == '\n') {
      incoming.trim();
      handleCommand(incoming);
      incoming = "";
    } else {
      incoming += c;
    }
  }
}

void handleCommand(const String &cmd) {
  if (cmd == "ON") {
    fill_solid(leds, LED_COUNT, CRGB::White);
    FastLED.show();
  } else if (cmd == "OFF") {
    clearStrip();
  }
}

void clearStrip() {
  fill_solid(leds, LED_COUNT, CRGB::Black);
  FastLED.show();
}
