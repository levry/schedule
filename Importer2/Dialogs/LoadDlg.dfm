object frmLoadDlg: TfrmLoadDlg
  Left = 244
  Top = 137
  BorderStyle = bsDialog
  Caption = #1056#1072#1089#1087#1088#1077#1076#1077#1083#1077#1085#1080#1077' '#1085#1072#1075#1088#1091#1079#1082#1080
  ClientHeight = 200
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    350
    200)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 30
    Width = 38
    Height = 13
    Caption = #1043#1088#1091#1087#1087#1072':'
  end
  object Label2: TLabel
    Left = 20
    Top = 55
    Width = 66
    Height = 13
    Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072':'
  end
  object lblGroup: TLabel
    Left = 105
    Top = 30
    Width = 3
    Height = 13
  end
  object lblSubject: TLabel
    Left = 105
    Top = 55
    Width = 3
    Height = 13
  end
  object Grid: TStringGrid
    Left = 15
    Top = 85
    Width = 320
    Height = 71
    BorderStyle = bsNone
    ColCount = 4
    DefaultRowHeight = 16
    RowCount = 4
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ScrollBars = ssNone
    TabOrder = 0
    OnSelectCell = GridSelectCell
  end
  object btnOk: TButton
    Left = 185
    Top = 170
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 270
    Top = 170
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
