unit SerialPort;

interface

uses
  Winapi.Windows, System.SysUtils;

type
  ESerialPortError = class(Exception);

  TSerialPort = class
  private
    FHandle: THandle;
    FPortName: string;
    FBaudRate: DWORD;
    procedure RaiseLastOSError(const Prefix: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Open(const APortName: string; ABaudRate: DWORD = CBR_9600);
    procedure Close;
    function IsOpen: Boolean;
    procedure WriteLine(const AText: string);

    property PortName: string read FPortName;
    property BaudRate: DWORD read FBaudRate;
  end;

implementation

constructor TSerialPort.Create;
begin
  inherited;
  FHandle := INVALID_HANDLE_VALUE;
end;

destructor TSerialPort.Destroy;
begin
  Close;
  inherited;
end;

procedure TSerialPort.RaiseLastOSError(const Prefix: string);
begin
  raise ESerialPortError.CreateFmt('%s. Код ошибки: %d', [Prefix, GetLastError]);
end;

procedure TSerialPort.Open(const APortName: string; ABaudRate: DWORD);
var
  Dcb: TDCB;
  Timeouts: TCommTimeouts;
  FullPortName: string;
begin
  if IsOpen then
    Close;

  if Trim(APortName) = '' then
    raise ESerialPortError.Create('COM-порт не указан.');

  FullPortName := '\\.\' + APortName;

  FHandle := CreateFile(
    PChar(FullPortName),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0
  );

  if FHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError('Не удалось открыть порт ' + APortName);

  FillChar(Dcb, SizeOf(Dcb), 0);
  Dcb.DCBlength := SizeOf(Dcb);

  if not GetCommState(FHandle, Dcb) then
    RaiseLastOSError('Не удалось получить параметры COM-порта');

  Dcb.BaudRate := ABaudRate;
  Dcb.ByteSize := 8;
  Dcb.Parity := NOPARITY;
  Dcb.StopBits := ONESTOPBIT;

  if not SetCommState(FHandle, Dcb) then
    RaiseLastOSError('Не удалось применить параметры COM-порта');

  SetupComm(FHandle, 1024, 1024);

  FillChar(Timeouts, SizeOf(Timeouts), 0);
  Timeouts.ReadIntervalTimeout := 50;
  Timeouts.ReadTotalTimeoutConstant := 50;
  Timeouts.ReadTotalTimeoutMultiplier := 10;
  Timeouts.WriteTotalTimeoutConstant := 50;
  Timeouts.WriteTotalTimeoutMultiplier := 10;

  if not SetCommTimeouts(FHandle, Timeouts) then
    RaiseLastOSError('Не удалось задать таймауты COM-порта');

  FPortName := APortName;
  FBaudRate := ABaudRate;
end;

procedure TSerialPort.Close;
begin
  if IsOpen then
  begin
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
    FPortName := '';
  end;
end;

function TSerialPort.IsOpen: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

procedure TSerialPort.WriteLine(const AText: string);
var
  Data: AnsiString;
  BytesWritten: DWORD;
begin
  if not IsOpen then
    raise ESerialPortError.Create('COM-порт не открыт.');

  Data := AnsiString(AText + #10);

  if not WriteFile(FHandle, Data[1], Length(Data), BytesWritten, nil) then
    RaiseLastOSError('Ошибка отправки данных в COM-порт');

  if BytesWritten <> DWORD(Length(Data)) then
    raise ESerialPortError.Create('Переданы не все данные в COM-порт.');
end;

end.
