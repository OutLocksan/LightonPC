# LightonPC (Delphi + Arduino via COM)

Пример простого Windows EXE на Delphi (VCL), который подключается к Arduino через COM-порт и отправляет команды:

- `ON` — включить ленту
- `OFF` — выключить ленту

## Что делает EXE

- Позволяет выбрать COM-порт и baud rate.
- Сохраняет настройки в `LightStripControl.ini` рядом с `.exe`.
- По кнопкам **LED ON** / **LED OFF** отправляет строки в COM-порт.

## Файлы проекта

- `LightStripControl.dpr` — входная точка VCL-приложения.
- `MainForm.pas` / `MainForm.dfm` — UI + логика кнопок и настроек.
- `SerialPort.pas` — низкоуровневая работа с COM через WinAPI.

## Ожидаемый протокол с Arduino

Приложение отправляет текстовые команды, завершая каждую переводом строки (`\n`):

- `ON\n`
- `OFF\n`

## Пример скетча Arduino

```cpp
const int LED_PIN = 8;
String incoming;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  Serial.begin(9600);
}

void loop() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\n') {
      incoming.trim();

      if (incoming == "ON") {
        digitalWrite(LED_PIN, HIGH);
      } else if (incoming == "OFF") {
        digitalWrite(LED_PIN, LOW);
      }

      incoming = "";
    } else {
      incoming += c;
    }
  }
}
```

## Как использовать

1. Залейте скетч в Arduino.
2. Подключите Arduino к ПК по USB.
3. Убедитесь, что скорость в приложении и в `Serial.begin(...)` совпадает (по умолчанию `9600`).
4. Запустите EXE, выберите COM-порт.
5. Нажмите **Connect**, затем **LED ON** / **LED OFF**.
