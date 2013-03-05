object frmStringListDlg: TfrmStringListDlg
  Left = 190
  Top = 104
  Width = 238
  Height = 327
  BorderStyle = bsSizeToolWin
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    230
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox: TListBox
    Left = 5
    Top = 5
    Width = 220
    Height = 256
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    TabOrder = 0
    OnDblClick = ListBoxDblClick
    OnDrawItem = ListBoxDrawItem
  end
  object btnOk: TButton
    Left = 70
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 150
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
