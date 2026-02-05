program LightStripControl;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
