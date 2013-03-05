object frmDataListDlg: TfrmDataListDlg
  Left = 191
  Top = 81
  Width = 238
  Height = 357
  BorderStyle = bsSizeToolWin
  Caption = #1057#1087#1080#1089#1086#1082
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    230
    330)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 70
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 150
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 5
    Top = 30
    Width = 221
    Height = 261
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    TabOrder = 2
    OnDblClick = ListBoxDblClick
    OnDrawItem = ListBoxDrawItem
  end
  object cbFilter: TComboBox
    Left = 5
    Top = 5
    Width = 221
    Height = 22
    Style = csOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 16
    TabOrder = 3
    OnChange = cbFilterChange
    OnDrawItem = cbFilterDrawItem
  end
end
