unit MainForm;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.IniFiles,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.StdCtrls,
  SerialPort;

type
  TFrmMain = class(TForm)
    BtnConnect: TButton;
    BtnDisconnect: TButton;
    BtnLedOn: TButton;
    BtnLedOff: TButton;
    CbComPort: TComboBox;
    EdBaudRate: TEdit;
    LblComPort: TLabel;
    LblBaudRate: TLabel;
    LblStatus: TLabel;
    PnlTop: TPanel;
    procedure BtnConnectClick(Sender: TObject);
    procedure BtnDisconnectClick(Sender: TObject);
    procedure BtnLedOffClick(Sender: TObject);
    procedure BtnLedOnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSerialPort: TSerialPort;
    function SettingsFileName: string;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure RefreshPorts;
    procedure SetControls;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

function TFrmMain.SettingsFileName: string;
begin
  Result := ChangeFileExt(ParamStr(0), '.ini');
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FSerialPort := TSerialPort.Create;
  RefreshPorts;
  LoadSettings;
  SetControls;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  FSerialPort.Free;
end;

procedure TFrmMain.RefreshPorts;
var
  I: Integer;
  PortName: string;
begin
  CbComPort.Items.BeginUpdate;
  try
    CbComPort.Items.Clear;
    for I := 1 to 50 do
    begin
      PortName := Format('COM%d', [I]);
      CbComPort.Items.Add(PortName);
    end;
  finally
    CbComPort.Items.EndUpdate;
  end;
end;

procedure TFrmMain.LoadSettings;
var
  Ini: TIniFile;
  PortName: string;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    PortName := Ini.ReadString('Serial', 'Port', 'COM3');
    EdBaudRate.Text := Ini.ReadString('Serial', 'BaudRate', '9600');
  finally
    Ini.Free;
  end;

  CbComPort.ItemIndex := CbComPort.Items.IndexOf(PortName);
  if CbComPort.ItemIndex < 0 then
    CbComPort.Text := PortName;
end;

procedure TFrmMain.SaveSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsFileName);
  try
    Ini.WriteString('Serial', 'Port', CbComPort.Text.Trim);
    Ini.WriteString('Serial', 'BaudRate', EdBaudRate.Text.Trim);
  finally
    Ini.Free;
  end;
end;

procedure TFrmMain.SetControls;
var
  Connected: Boolean;
begin
  Connected := FSerialPort.IsOpen;
  BtnConnect.Enabled := not Connected;
  BtnDisconnect.Enabled := Connected;
  BtnLedOn.Enabled := Connected;
  BtnLedOff.Enabled := Connected;

  if Connected then
    LblStatus.Caption := 'Статус: подключено к ' + FSerialPort.PortName
  else
    LblStatus.Caption := 'Статус: не подключено';
end;

procedure TFrmMain.BtnConnectClick(Sender: TObject);
var
  BaudRate: Integer;
begin
  if not TryStrToInt(EdBaudRate.Text.Trim, BaudRate) then
  begin
    MessageDlg('Укажите корректный baud rate (например, 9600).', mtError, [mbOK], 0);
    Exit;
  end;

  try
    FSerialPort.Open(CbComPort.Text.Trim, BaudRate);
    SaveSettings;
    SetControls;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmMain.BtnDisconnectClick(Sender: TObject);
begin
  FSerialPort.Close;
  SetControls;
end;

procedure TFrmMain.BtnLedOnClick(Sender: TObject);
begin
  try
    FSerialPort.WriteLine('ON');
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFrmMain.BtnLedOffClick(Sender: TObject);
begin
  try
    FSerialPort.WriteLine('OFF');
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
