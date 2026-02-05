import json
import os
import sys
import tkinter as tk
from tkinter import ttk, messagebox

import serial
from serial.tools import list_ports


DEFAULT_PORT = "COM3"
DEFAULT_BAUD = 9600


def app_base_path() -> str:
    if getattr(sys, "frozen", False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))


def settings_path() -> str:
    return os.path.join(app_base_path(), "lightonpc_settings.json")


class Settings:
    def __init__(self, com_port: str = DEFAULT_PORT, baud_rate: int = DEFAULT_BAUD) -> None:
        self.com_port = com_port
        self.baud_rate = baud_rate

    @staticmethod
    def load() -> "Settings":
        path = settings_path()
        if not os.path.exists(path):
            return Settings()

        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            com_port = str(data.get("com_port", DEFAULT_PORT))
            baud_rate = int(data.get("baud_rate", DEFAULT_BAUD))
            return Settings(com_port, baud_rate)
        except Exception:
            return Settings()

    def save(self) -> None:
        data = {
            "com_port": self.com_port,
            "baud_rate": self.baud_rate,
        }
        with open(settings_path(), "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)


class LightonApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("LED Strip Control (Python)")
        self.geometry("500x250")
        self.resizable(False, False)

        self.serial_port: serial.Serial | None = None

        self._build_ui()
        self._load_settings()
        self.refresh_ports()
        self._set_controls()

    def _build_ui(self) -> None:
        frm = ttk.Frame(self, padding=12)
        frm.pack(fill="both", expand=True)

        ttk.Label(frm, text="COM port:").grid(row=0, column=0, sticky="w", pady=4)
        self.cb_port = ttk.Combobox(frm, width=18)
        self.cb_port.grid(row=0, column=1, sticky="w", pady=4)

        ttk.Label(frm, text="Baud rate:").grid(row=1, column=0, sticky="w", pady=4)
        self.ed_baud = ttk.Entry(frm, width=20)
        self.ed_baud.grid(row=1, column=1, sticky="w", pady=4)

        self.btn_refresh = ttk.Button(frm, text="Refresh ports", command=self.refresh_ports)
        self.btn_refresh.grid(row=0, column=2, padx=8)

        self.btn_connect = ttk.Button(frm, text="Connect", command=self.connect_port)
        self.btn_connect.grid(row=1, column=2, padx=8)

        self.btn_disconnect = ttk.Button(frm, text="Disconnect", command=self.disconnect_port)
        self.btn_disconnect.grid(row=1, column=3, padx=8)

        self.btn_on = ttk.Button(frm, text="LED ON", command=lambda: self.send_command("ON"))
        self.btn_on.grid(row=3, column=0, columnspan=2, sticky="ew", pady=(24, 8))

        self.btn_off = ttk.Button(frm, text="LED OFF", command=lambda: self.send_command("OFF"))
        self.btn_off.grid(row=3, column=2, columnspan=2, sticky="ew", pady=(24, 8), padx=(8, 0))

        self.lbl_status = ttk.Label(frm, text="Status: not connected")
        self.lbl_status.grid(row=4, column=0, columnspan=4, sticky="w", pady=(18, 0))

        self.lbl_signature = ttk.Label(frm, text="by Locksan")
        self.lbl_signature.grid(row=5, column=3, sticky="se", pady=(8, 0))

        for i in range(4):
            frm.columnconfigure(i, weight=1)

        frm.rowconfigure(5, weight=1)

        self.protocol("WM_DELETE_WINDOW", self._on_close)

    def _load_settings(self) -> None:
        cfg = Settings.load()
        self.cb_port.set(cfg.com_port)
        self.ed_baud.delete(0, tk.END)
        self.ed_baud.insert(0, str(cfg.baud_rate))

    def _save_settings(self) -> None:
        baud = DEFAULT_BAUD
        try:
            baud = int(self.ed_baud.get().strip())
        except ValueError:
            pass

        Settings(self.cb_port.get().strip(), baud).save()

    def refresh_ports(self) -> None:
        current = self.cb_port.get().strip()
        ports = sorted([p.device for p in list_ports.comports()], key=lambda s: s.lower())

        if not ports:
            ports = [f"COM{i}" for i in range(1, 21)]

        self.cb_port["values"] = ports

        if current:
            self.cb_port.set(current)
        elif ports:
            self.cb_port.set(ports[0])

    def connect_port(self) -> None:
        com_port = self.cb_port.get().strip()

        try:
            baud = int(self.ed_baud.get().strip())
            if baud <= 0:
                raise ValueError
        except ValueError:
            messagebox.showerror("Ошибка", "Укажите корректный baud rate (например, 9600).")
            return

        try:
            self.disconnect_port(silent=True)
            self.serial_port = serial.Serial(
                port=com_port,
                baudrate=baud,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=0.5,
                write_timeout=0.5,
            )
            self._save_settings()
            self._set_controls()
        except Exception as exc:
            self.serial_port = None
            messagebox.showerror("Ошибка COM", str(exc))
            self._set_controls()

    def disconnect_port(self, silent: bool = False) -> None:
        try:
            if self.serial_port is not None and self.serial_port.is_open:
                self.serial_port.close()
        except Exception as exc:
            if not silent:
                messagebox.showerror("Ошибка COM", str(exc))
        finally:
            self.serial_port = None
            self._set_controls()

    def send_command(self, command: str) -> None:
        if self.serial_port is None or not self.serial_port.is_open:
            messagebox.showerror("Ошибка COM", "COM-порт не открыт.")
            return

        try:
            payload = (command + "\n").encode("ascii")
            self.serial_port.write(payload)
            self.serial_port.flush()
        except Exception as exc:
            messagebox.showerror("Ошибка COM", str(exc))

    def _set_controls(self) -> None:
        connected = self.serial_port is not None and self.serial_port.is_open

        self.btn_connect.configure(state="disabled" if connected else "normal")
        self.btn_disconnect.configure(state="normal" if connected else "disabled")
        self.btn_on.configure(state="normal" if connected else "disabled")
        self.btn_off.configure(state="normal" if connected else "disabled")

        if connected and self.serial_port is not None:
            self.lbl_status.configure(text=f"Status: connected to {self.serial_port.port}")
        else:
            self.lbl_status.configure(text="Status: not connected")

    def _on_close(self) -> None:
        self._save_settings()
        self.disconnect_port(silent=True)
        self.destroy()


if __name__ == "__main__":
    app = LightonApp()
    app.mainloop()
