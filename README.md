# LightonPC (Python + Arduino via COM)

Windows EXE на Python (Tkinter), который подключается к Arduino через COM-порт и отправляет команды:

- `ON` — включить ленту
- `OFF` — выключить ленту

## Что делает EXE

- Позволяет выбрать COM-порт и baud rate.
- Сохраняет настройки в JSON рядом с `.exe` (`lightonpc_settings.json`).
- По кнопкам **LED ON** / **LED OFF** отправляет команды в COM-порт.

## Файлы проекта

- `lightonpc_py/main.py` — GUI + логика COM-управления и настройки.
- `requirements.txt` — зависимости Python.
- `build_exe.bat` — сборка EXE через PyInstaller.

## Протокол с Arduino

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

## Как собрать EXE на Windows

1. Установите Python 3.10+.
2. Откройте `cmd` в папке проекта.
3. Выполните:

```bat
build_exe.bat
```

Готовый файл будет здесь:

- `dist\LightonPC-Python.exe`

## Запуск без EXE (для разработки)

```bash
python lightonpc_py/main.py
```
