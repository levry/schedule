object frmExportDeclareDlg: TfrmExportDeclareDlg
  Left = 246
  Top = 137
  BorderStyle = bsDialog
  Caption = #1069#1082#1089#1087#1086#1088#1090' '#1079#1072#1103#1074#1086#1082
  ClientHeight = 249
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    336
    249)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 85
    Width = 86
    Height = 21
    AutoSize = False
    Caption = #1050#1072#1092#1077#1076#1088#1072':'
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 15
    Top = 55
    Width = 86
    Height = 21
    AutoSize = False
    Caption = #1057#1077#1084#1077#1089#1090#1088':'
    Layout = tlCenter
  end
  object lblSem: TLabel
    Left = 110
    Top = 55
    Width = 211
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Layout = tlCenter
  end
  object Bevel1: TBevel
    Left = 0
    Top = 208
    Width = 336
    Height = 41
    Align = alBottom
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 15
    Top = 115
    Width = 86
    Height = 21
    AutoSize = False
    Caption = #1055#1086#1090#1086#1082#1080':'
    Layout = tlCenter
  end
  object InfoPanel: TPanel
    Left = 0
    Top = 0
    Width = 336
    Height = 41
    Align = alTop
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1074#1099#1093#1086#1076#1085#1086#1081' '#1092#1072#1081#1083', '#1072' '#1090#1072#1082#1078#1077' '#1090#1080#1087' '#1087#1086#1090#1086#1082#1086#1074
    Color = clWhite
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 15
    Top = 145
    Width = 311
    Height = 51
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1060#1072#1081#1083
    TabOrder = 4
    DesignSize = (
      311
      51)
    object lblFile: TLabel
      Left = 10
      Top = 20
      Width = 261
      Height = 21
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Layout = tlCenter
    end
    object btnOpen: TSpeedButton
      Left = 280
      Top = 20
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
      Glyph.Data = {
        46020000424D460200000000000036000000280000000E0000000C0000000100
        1800000000001002000000000000000000000000000000000000FF00FF000000
        000000000000000000000000000000000000000000000000000000FF00FFFF00
        FFFF00FF0400FF00FF0000000000008080808080808080808080808080808080
        80808080808080000000FF00FFFF00FF0200FF00FF000000FFFFFF0000008080
        80808080808080808080808080808080808080808080000000FF00FFBE81FF00
        FF000000FFFFFFFFFFFF00000080808080808080808080808080808080808080
        8080808080000000C300FF00FF000000FFFFFFFFFFFFFFFFFF00000000000000
        00000000000000000000000000000000000000001D03FF00FF000000FFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF00FFFF00FFFF00FF
        3600FF00FF000000FFFFFFFFFFFFFFFFFF000000000000000000000000000000
        000000FF00FFFF00FFFF00FF0200FF00FFFF00FF000000000000000000FF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFBF81FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000000000000000
        00FF00FF4B01FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FF000000000000FF00FF1D03FF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FF000000FF00FFFF00FFFF00FF000000FF00FF000000FF00FFBE81FF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000000000FF00FFFF
        00FFFF00FFFF00FF4D01}
      OnClick = OnBtnsClick
    end
  end
  object btnOk: TButton
    Tag = 1
    Left = 169
    Top = 218
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
    Tag = 2
    Left = 254
    Top = 218
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object cbType: TComboBox
    Left = 110
    Top = 115
    Width = 145
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = #1051#1077#1082#1094#1080#1080
    Items.Strings = (
      #1051#1077#1082#1094#1080#1080
      #1055#1088#1072#1082#1090#1080#1082#1072
      #1051#1072#1073#1086#1088#1072#1090#1086#1088#1080#1103)
  end
  object cbKafedra: TComboBox
    Left = 110
    Top = 85
    Width = 211
    Height = 22
    Style = csOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 16
    TabOrder = 5
    OnDrawItem = ComboDrawItem
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel files|*.xls|Any files|*.*'
    Left = 245
    Top = 155
  end
end
