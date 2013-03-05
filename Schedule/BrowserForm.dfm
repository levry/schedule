object fmBrowser: TfmBrowser
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  AutoScroll = False
  TabOrder = 0
  object CaptionLabel: TLabel
    Left = 0
    Top = 0
    Width = 320
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
  object HTMLabel: THTMLabel
    Left = 0
    Top = 202
    Width = 320
    Height = 38
    Align = alBottom
    ColorTo = clNone
    AnchorHint = False
    AutoSizing = False
    AutoSizeType = asVertical
    BevelOuter = bvRaised
    Color = clInfoBk
    Ellipsis = False
    GradientType = gtFullHorizontal
    HintShowFull = False
    Hover = False
    HoverColor = clNone
    HoverFontColor = clNone
    HTMLHint = False
    LineWidth = 0
    ParentColor = False
    ShadowColor = clGray
    ShadowOffset = 2
    URLColor = clBlue
    VAlignment = tvaCenter
    Visible = False
    OnAnchorClick = HTMLabelAnchorClick
    Version = '1.7.1.1'
  end
  object TreeView: TTreeView
    Left = 0
    Top = 40
    Width = 320
    Height = 162
    Align = alClient
    DragMode = dmAutomatic
    Images = BrowseImageList
    Indent = 19
    PopupMenu = PopupMenu
    ReadOnly = True
    RightClickSelect = True
    ShowLines = False
    TabOrder = 0
    OnDblClick = TreeViewDblClick
    OnDeletion = TreeViewDeletion
    OnExpanding = TreeViewExpanding
    OnGetImageIndex = TreeViewGetImageIndex
    OnKeyDown = TreeViewKeyDown
    OnMouseUp = TreeViewMouseUp
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 18
    Width = 320
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = BrowseImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnViewKafAll: TToolButton
      Left = 0
      Top = 0
      Action = actViewPerformKaf
      Grouped = True
      Style = tbsCheck
    end
    object btnViewKafGrp: TToolButton
      Left = 23
      Top = 0
      Action = actViewFacultyKaf
      Grouped = True
      Style = tbsCheck
    end
    object btnViewDeclare: TToolButton
      Left = 46
      Top = 0
      Action = actViewDeclare
      Grouped = True
      Style = tbsCheck
    end
  end
  object BrowseImageList: TImageList
    Left = 200
    Top = 20
  end
  object ActionList: TActionList
    Images = BrowseImageList
    Left = 200
    Top = 70
    object actViewPerformKaf: TAction
      Tag = 1
      Caption = #1050#1072#1092#1077#1076#1088#1099'-'#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1080
      Hint = #1050#1072#1092#1077#1076#1088#1099'-'#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1080
      ImageIndex = 2
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actViewFacultyKaf: TAction
      Tag = 2
      Caption = #1050#1072#1092#1077#1076#1088#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      Hint = #1050#1072#1092#1077#1076#1088#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      ImageIndex = 6
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actViewDeclare: TAction
      Tag = 4
      Caption = #1044#1080#1089#1094#1080#1087#1080#1083#1085#1099
      Hint = #1044#1080#1089#1094#1080#1087#1080#1083#1085#1099
      ImageIndex = 7
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdate: TAction
      Tag = -1
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actSelect: TAction
      Tag = 3
      Caption = #1042#1099#1073#1088#1072#1090#1100
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object PopupMenu: TPopupMenu
    Left = 200
    Top = 125
    object btnSelect: TMenuItem
      Action = actSelect
      Default = True
    end
    object btnUpdate: TMenuItem
      Action = actUpdate
    end
  end
end
