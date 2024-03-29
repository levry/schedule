object frmExportSourcePage: TfrmExportSourcePage
  Left = 269
  Top = 167
  AutoScroll = False
  ClientHeight = 390
  ClientWidth = 374
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    374
    390)
  PixelsPerInch = 96
  TextHeight = 13
  object lbList: TCheckListBox
    Left = 195
    Top = 24
    Width = 156
    Height = 302
    OnClickCheck = lbListClickCheck
    Anchors = [akLeft, akTop, akBottom]
    DragMode = dmAutomatic
    ItemHeight = 13
    TabOrder = 0
    OnDragDrop = lbListDragDrop
    OnDragOver = lbListDragOver
  end
  object chkAll: TCheckBox
    Left = 194
    Top = 5
    Width = 97
    Height = 17
    Caption = #1042#1077#1089#1100' '#1089#1087#1080#1089#1086#1082
    TabOrder = 1
    OnClick = chkAllClick
  end
  object GroupBox: TGroupBox
    Left = 25
    Top = 336
    Width = 331
    Height = 46
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1060#1072#1081#1083
    TabOrder = 2
    DesignSize = (
      331
      46)
    object lblFile: TLabel
      Left = 10
      Top = 15
      Width = 259
      Height = 22
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      Layout = tlCenter
    end
    object SaveBtn: TSpeedButton
      Tag = 3
      Left = 300
      Top = 15
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
      OnClick = SaveBtnClick
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel files|*.xls|Any files|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 35
    Top = 280
  end
end
