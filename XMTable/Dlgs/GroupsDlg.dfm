object frmGroupsDlg: TfrmGroupsDlg
  Left = 191
  Top = 102
  BorderStyle = bsDialog
  Caption = #1043#1088#1091#1087#1087#1099
  ClientHeight = 350
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    250
    350)
  PixelsPerInch = 96
  TextHeight = 13
  object btnGroupAll: TSpeedButton
    Tag = 1
    Left = 10
    Top = 5
    Width = 23
    Height = 22
    Hint = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077' '#1075#1088#1091#1087#1087#1099
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000C40E0000C40E00001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDCCCCC0DDDDDDDDD0CC000DCC0DDDDDDD00FF0CC0DDDDDDDDD0F0000DD
      DDDDDDDD0FFFF0DDDDDDDDD00FFFF000DDDDDD0000FFFF0F0DDDDD000FFF00FF
      0DDDDD0000FFF0FFF0DDDD00000000F00DDDDDD0000000FF0DDDDDDD00000000
      D0DDDDDDDDD0000000DDDDDDDDDD00000DDDDDDDDDDDDDDDDDDD}
    ParentShowHint = False
    ShowHint = True
    OnClick = OnBtnsClick
  end
  object btnGroupCourse: TSpeedButton
    Tag = 2
    Left = 35
    Top = 5
    Width = 23
    Height = 22
    Hint = #1042#1099#1073#1086#1088' '#1075#1088#1091#1087#1087' '#1082#1091#1088#1089#1072
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
    ParentShowHint = False
    ShowHint = True
    OnClick = OnBtnsClick
  end
  object btnOk: TButton
    Left = 90
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 170
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object lbGroups: TCheckListBox
    Left = 5
    Top = 30
    Width = 240
    Height = 281
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    Style = lbOwnerDrawFixed
    TabOrder = 2
    OnDrawItem = lbGroupsDrawItem
  end
  object CourseMenu: TPopupMenu
    Left = 190
    Top = 55
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
