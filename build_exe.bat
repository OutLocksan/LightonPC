@echo off
setlocal

REM Build standalone Windows EXE from Python app.
REM Requires Python 3.10+ and dependencies from requirements.txt.

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

pyinstaller --noconfirm --onefile --windowed --name LightonPC-Python lightonpc_py/main.py

echo.
echo Build finished. EXE path:
echo dist\LightonPC-Python.exe
