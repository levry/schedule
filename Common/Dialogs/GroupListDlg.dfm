object frmGroupListDlg: TfrmGroupListDlg
  Left = 191
  Top = 104
  BorderStyle = bsDialog
  Caption = #1043#1088#1091#1087#1087#1099
  ClientHeight = 300
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    220
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object btnGroupCourse: TSpeedButton
    Left = 5
    Top = 5
    Width = 23
    Height = 22
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000C40E0000C40E00001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDCCCCC0DDDDDDDDD0CC000DCC0DDDDDDD00FF0CC0DDDDDDDDD0F0000DDDD
      D0DDDD0FFFF0DDDD000DD00FFFF000D000000000FFFF0F0DDDDD000FFF00FF0D
      DDDD0000FFF0FFF0DDDD00000000F00DDDDDD0000000FF0DDDDDDD00000000D0
      DDDDDDDDD0000000DDDDDDDDDD00000DDDDDDDDDDDDDDDDDDDDD}
    OnClick = btnGroupCourseClick
  end
  object btnOk: TButton
    Left = 60
    Top = 270
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 140
    Top = 270
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 5
    Top = 35
    Width = 210
    Height = 226
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 16
    TabOrder = 2
    OnDblClick = ListBoxDblClick
    OnDrawItem = ListBoxDrawItem
  end
  object CourseMenu: TPopupMenu
    Left = 165
    Top = 125
    object mnuCourse1: TMenuItem
      Tag = 1
      Caption = '1 '#1082#1091#1088#1089
      OnClick = MenuCourseClick
    end
    object mnuCourse2: TMenuItem
      Tag = 2
      Caption = '2 '#1082#1091#1088#1089
      OnClick = MenuCourseClick
    end
    object mnuCourse3: TMenuItem
      Tag = 3
      Caption = '3 '#1082#1091#1088#1089
      OnClick = MenuCourseClick
    end
    object mnuCourse4: TMenuItem
      Tag = 4
      Caption = '4 '#1082#1091#1088#1089
      OnClick = MenuCourseClick
    end
    object mnuCourse5: TMenuItem
      Tag = 5
      Caption = '5 '#1082#1091#1088#1089
      OnClick = MenuCourseClick
    end
  end
end
