object frmAboutDlg: TfrmAboutDlg
  Left = 191
  Top = 105
  BorderStyle = bsDialog
  Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
  ClientHeight = 260
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    300
    260)
  PixelsPerInch = 96
  TextHeight = 13
  object lblProductName: TLabel
    Left = 124
    Top = 25
    Width = 167
    Height = 30
    Anchors = [akTop, akRight]
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object lblVersion: TLabel
    Left = 154
    Top = 60
    Width = 137
    Height = 15
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = #1042#1077#1088#1089#1080#1103': '
  end
  object lblVersionDB: TLabel
    Left = 154
    Top = 80
    Width = 137
    Height = 15
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = #1042#1077#1088#1089#1080#1103' '#1041#1044': '
  end
  object lblDeveloper: TLabel
    Left = 124
    Top = 105
    Width = 167
    Height = 15
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = #169' '#1056#1080#1089#1082#1086#1074' '#1051'.'#1042'., 2006'
  end
  object imgLogo: TImage
    Left = 5
    Top = 5
    Width = 100
    Height = 250
  end
  object lblOthers: TLabel
    Left = 124
    Top = 125
    Width = 167
    Height = 46
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = #1050#1086#1085#1089#1091#1083#1100#1090#1072#1085#1090#1099':'
  end
  object btnOk: TButton
    Left = 220
    Top = 230
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
end
