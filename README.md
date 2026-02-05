# LightonPC (Python + Arduino via COM)

Windows EXE на Python (Tkinter), который подключается к Arduino через COM-порт и отправляет команды:

- `ON` — включить ленту
- `OFF` — выключить ленту

## Что делает EXE

- Позволяет выбрать COM-порт и baud rate.
- Сохраняет настройки в JSON рядом с `.exe` (`lightonpc_settings.json`).
- По кнопкам **LED ON** / **LED OFF** отправляет команды в COM-порт.
- Показывает шильдик **by Locksan** в правом нижнем углу окна.

## Файлы проекта

- `lightonpc_py/main.py` — GUI + логика COM-управления и настройки.
- `arduino/fastled_pc_control.ino` — Arduino-скетч на FastLED для команд с ПК.
- `requirements.txt` — зависимости Python.
- `build_exe.bat` — сборка EXE через PyInstaller.

## Протокол с Arduino

Приложение отправляет текстовые команды, завершая каждую переводом строки (`\n`):

- `ON\n`
- `OFF\n`

## Arduino (FastLED)

Откройте `arduino/fastled_pc_control.ino`. Для упрощенного редактирования все ключевые параметры вынесены в начало файла:

- `LED_PIN` — пин ленты
- `LED_COUNT` — общее число диодов
- `SERIAL_BAUD` — скорость COM
- `LED_TYPE`, `COLOR_ORDER`, `BRIGHTNESS` — параметры ленты

Команды с ПК:

- `ON` → включает ленту белым
- `OFF` → выключает ленту

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
