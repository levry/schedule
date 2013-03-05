object frmGroupsDlg: TfrmGroupsDlg
  Left = 191
  Top = 81
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
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 250
    Height = 30
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = True
    BorderWidth = 2
    Caption = 'ToolBar'
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    Indent = 5
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object btnGroupAll: TToolButton
      Left = 5
      Top = 0
      Action = actGroupAll
      ImageIndex = 23
    end
    object btnGroupCourse: TToolButton
      Left = 28
      Top = 0
      Action = actGroupCourse
      DropdownMenu = CourseMenu
      ImageIndex = 19
      Style = tbsDropDown
    end
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 195
    Top = 65
    object actGroupAll: TAction
      Tag = -1
      Caption = #1042#1089#1077' '#1075#1088#1091#1087#1087#1099
      Hint = #1042#1089#1077' '#1075#1088#1091#1087#1087#1099
      ImageIndex = 20
      OnExecute = GroupActionsExecute
      OnUpdate = GroupActionsUpdate
    end
    object actGroupCourse: TAction
      Tag = -2
      Caption = #1050#1091#1088#1089
      Hint = #1053#1086#1084#1077#1088' '#1082#1091#1088#1089#1072
      ImageIndex = 16
      OnExecute = GroupActionsExecute
      OnUpdate = GroupActionsUpdate
    end
  end
  object CourseMenu: TPopupMenu
    Left = 195
    Top = 115
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
