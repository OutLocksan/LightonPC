object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'LED Strip Control'
  ClientHeight = 214
  ClientWidth = 424
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 424
    Height = 96
    Align = alTop
    TabOrder = 0
    object LblComPort: TLabel
      Left = 16
      Top = 16
      Width = 54
      Height = 15
      Caption = 'COM port:'
    end
    object LblBaudRate: TLabel
      Left = 16
      Top = 52
      Width = 60
      Height = 15
      Caption = 'Baud rate:'
    end
    object CbComPort: TComboBox
      Left = 88
      Top = 12
      Width = 121
      Height = 23
      Style = csDropDown
      TabOrder = 0
      Text = 'COM3'
    end
    object EdBaudRate: TEdit
      Left = 88
      Top = 48
      Width = 121
      Height = 23
      TabOrder = 1
      Text = '9600'
    end
    object BtnConnect: TButton
      Left = 232
      Top = 12
      Width = 81
      Height = 25
      Caption = 'Connect'
      TabOrder = 2
      OnClick = BtnConnectClick
    end
    object BtnDisconnect: TButton
      Left = 320
      Top = 12
      Width = 89
      Height = 25
      Caption = 'Disconnect'
      TabOrder = 3
      OnClick = BtnDisconnectClick
    end
  end
  object BtnLedOn: TButton
    Left = 40
    Top = 120
    Width = 153
    Height = 41
    Caption = 'LED ON'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = BtnLedOnClick
  end
  object BtnLedOff: TButton
    Left = 224
    Top = 120
    Width = 153
    Height = 41
    Caption = 'LED OFF'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = BtnLedOffClick
  end
  object LblStatus: TLabel
    Left = 16
    Top = 184
    Width = 119
    Height = 15
    Caption = 'Status: not connected'
  end
end
