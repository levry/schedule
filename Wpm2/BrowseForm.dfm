object frmBrowser: TfrmBrowser
  Left = 189
  Top = 104
  AutoScroll = False
  Caption = 'frmBrowser'
  ClientHeight = 453
  ClientWidth = 244
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object CaptionLabel: TLabel
    Left = 0
    Top = 0
    Width = 244
    Height = 18
    Align = alTop
    AutoSize = False
    Caption = ' '#1057#1090#1088#1091#1082#1090#1091#1088#1072
    Color = clInactiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object TreeView: TTreeView
    Left = 0
    Top = 40
    Width = 244
    Height = 413
    Align = alClient
    Images = TreeList
    Indent = 19
    ParentShowHint = False
    PopupMenu = PopupMenu
    ReadOnly = True
    RightClickSelect = True
    ShowHint = True
    TabOrder = 0
    OnDblClick = TreeViewDblClick
    OnDeletion = TreeViewDeletion
    OnExpanding = TreeViewExpanding
    OnGetImageIndex = TreeViewGetImageIndex
    OnMouseUp = TreeViewMouseUp
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 18
    Width = 244
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = TreeList
    TabOrder = 1
    object btnGroupBy: TToolButton
      Left = 0
      Top = 0
      Action = actGroupView
      DropdownMenu = mnuGroupBy
      Style = tbsDropDown
    end
  end
  object ActionList: TActionList
    Images = TreeList
    Left = 175
    Top = 95
    object actGroupKafedra: TAction
      Tag = 1
      Caption = #1043#1088#1091#1087#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1086' '#1082#1072#1092#1077#1076#1088#1072#1084
      ImageIndex = 5
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actGroupCourse: TAction
      Tag = 2
      Caption = #1043#1088#1091#1087#1087#1080#1088#1086#1074#1072#1090#1100' '#1087#1086' '#1082#1091#1088#1089#1072#1084
      Checked = True
      ImageIndex = 6
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actGroupView: TAction
      Tag = 3
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actSelect: TAction
      Tag = 5
      Caption = #1042#1099#1073#1088#1072#1090#1100
      Hint = #1042#1099#1073#1088#1072#1090#1100
      ShortCut = 13
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdate: TAction
      Tag = 4
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ShortCut = 116
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object TreeList: TImageList
    Left = 175
    Top = 145
  end
  object mnuGroupBy: TPopupMenu
    Images = TreeList
    Left = 175
    Top = 45
    object N1: TMenuItem
      Action = actGroupKafedra
    end
    object N2: TMenuItem
      Action = actGroupCourse
    end
  end
  object setDBView: TADODataSet
    Parameters = <>
    Left = 75
    Top = 45
  end
  object PopupMenu: TPopupMenu
    Left = 175
    Top = 195
    object mnuSelect: TMenuItem
      Action = actSelect
      Default = True
    end
    object mnuUpdate: TMenuItem
      Action = actUpdate
    end
  end
end
