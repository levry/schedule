object frmCopyDlg: TfrmCopyDlg
  Left = 189
  Top = 104
  BorderStyle = bsDialog
  ClientHeight = 356
  ClientWidth = 245
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    245
    356)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 0
    Width = 245
    Height = 106
    Align = alTop
    Shape = bsBottomLine
  end
  object btnAdd: TSpeedButton
    Left = 10
    Top = 290
    Width = 23
    Height = 22
    Action = actCloneAdd
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000C40E0000C40E00001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD00000DDDDDDDDDDD0AAA0DD
      DDDDDDDDD0AAA0DDDDDDDD0000AAA0000DDDDD0AAAAAAAAA0DDDDD0AAAAAAAAA
      0DDDDD0AAAAAAAAA0DDDDD0000AAA0000DDDDDDDD0AAA0DDDDDDDDDDD0AAA0DD
      DDDDDDDDD00000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
    ParentShowHint = False
    ShowHint = True
  end
  object btnDel: TSpeedButton
    Left = 35
    Top = 290
    Width = 23
    Height = 22
    Action = actCloneRemove
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000C40E0000C40E00001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDD000000000000DDDD0BBBBBBBBBB0DDDD0BBBBBBBBB
      B0DDDD0BBBBBBBBBB0DDDD000000000000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
    ParentShowHint = False
    ShowHint = True
  end
  object lblSource: TLabel
    Left = 30
    Top = 35
    Width = 205
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    WordWrap = True
  end
  object Label1: TLabel
    Left = 10
    Top = 10
    Width = 190
    Height = 21
    AutoSize = False
    Layout = tlCenter
  end
  object Bevel1: TBevel
    Left = 0
    Top = 317
    Width = 245
    Height = 39
    Align = alBottom
    Shape = bsTopLine
  end
  object ListBox: TListBox
    Left = 10
    Top = 115
    Width = 225
    Height = 171
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 16
    TabOrder = 0
    OnDrawItem = ListBoxDrawItem
  end
  object btnOk: TButton
    Left = 85
    Top = 326
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 165
    Top = 326
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object chkDelSource: TCheckBox
    Left = 145
    Top = 80
    Width = 91
    Height = 17
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 180
    Top = 130
    object actCloneAdd: TAction
      Tag = 1
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100
      ShortCut = 45
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actCloneRemove: TAction
      Tag = 2
      Hint = #1059#1076#1072#1083#1080#1090#1100
      ShortCut = 46
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
end
