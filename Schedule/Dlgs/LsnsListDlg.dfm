object frmLsnsListDlg: TfrmLsnsListDlg
  Left = 189
  Top = 104
  Width = 570
  Height = 350
  BorderStyle = bsSizeToolWin
  Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1079#1072#1085#1103#1090#1080#1103
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 562
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = ImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnSelect: TToolButton
      Left = 0
      Top = 0
      Action = actSelect
    end
    object btnCancel: TToolButton
      Left = 23
      Top = 0
      Action = actCancel
    end
    object ToolButton2: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object btnViewLc: TToolButton
      Left = 54
      Top = 0
      Action = actViewLc
      Grouped = True
      Style = tbsCheck
    end
    object btnViewPr: TToolButton
      Left = 77
      Top = 0
      Action = actViewPr
      Grouped = True
      Style = tbsCheck
    end
    object btnViewLb: TToolButton
      Left = 100
      Top = 0
      Action = actViewLb
      Grouped = True
      Style = tbsCheck
    end
    object ToolButton1: TToolButton
      Left = 123
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object btnUpdate: TToolButton
      Left = 131
      Top = 0
      Action = actUpdate
    end
  end
  object vstLsns: TVirtualStringTree
    Left = 0
    Top = 22
    Width = 562
    Height = 282
    Align = alClient
    Colors.GridLineColor = clBtnText
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Images = ImageList
    Header.Options = [hoShowHint, hoShowImages, hoVisible, hoAutoSpring]
    Header.Style = hsFlatButtons
    Images = ImageList
    ParentBackground = False
    TabOrder = 1
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnBeforeItemErase = vstLsnsBeforeItemErase
    OnColumnClick = vstLsnsColumnClick
    OnDblClick = vstLsnsDblClick
    OnGetText = vstLsnsGetText
    OnGetImageIndex = vstLsnsGetImageIndex
    Columns = <
      item
        Alignment = taCenter
        ImageIndex = 6
        Margin = 0
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 0
        Width = 31
        WideHint = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
      end
      item
        Alignment = taCenter
        ImageIndex = 8
        Margin = 0
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 1
        Width = 24
        WideHint = #1044#1086#1089#1090#1091#1087#1085#1086' '#1095#1072#1089#1086#1074
      end
      item
        Alignment = taCenter
        ImageIndex = 7
        Margin = 0
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 2
        Width = 24
        WideHint = #1044#1086#1089#1090#1091#1087#1077#1085' '#1087#1086#1090#1086#1082
      end
      item
        ImageIndex = 9
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 3
        Width = 24
        WideHint = #1055#1086#1076#1075#1088#1091#1087#1087#1072
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring]
        Position = 4
        Width = 210
        WideText = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        WideHint = #1053#1072#1079#1074#1072#1085#1080#1077' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1099
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 5
        Width = 150
        WideText = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 6
        WideText = #1063#1072#1089#1099
        WideHint = #1042#1089#1077#1075#1086' / '#1076#1086#1089#1090#1091#1087#1085#1086
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 7
        Width = 45
        WideText = #1055#1086#1090#1086#1082
        WideHint = #1053#1072#1083#1080#1095#1080#1077' '#1087#1086#1090#1086#1082#1072
      end>
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 304
    Width = 562
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
    OnResize = StatusBarResize
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 420
    Top = 65
    object actViewLc: TAction
      Tag = 1
      Caption = #1051#1077#1082#1094#1080#1080
      Hint = #1051#1077#1082#1094#1080#1080
      ImageIndex = 2
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actViewPr: TAction
      Tag = 2
      Caption = #1055#1088#1072#1082#1090#1080#1082#1080
      Hint = #1055#1088#1072#1082#1090#1080#1082#1080
      ImageIndex = 3
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actViewLb: TAction
      Tag = 3
      Caption = #1051#1072#1073#1086#1088#1072#1090#1086#1088#1085#1099#1077
      Hint = #1051#1072#1073#1086#1088#1072#1090#1086#1088#1085#1099#1077
      ImageIndex = 4
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdate: TAction
      Tag = -1
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 5
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actSelect: TAction
      Tag = 4
      Caption = #1042#1099#1073#1088#1072#1090#1100
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1079#1072#1085#1103#1090#1080#1077
      ImageIndex = 0
      ShortCut = 13
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actCancel: TAction
      Tag = 5
      Caption = #1054#1090#1084#1077#1085#1072
      Hint = #1054#1090#1084#1077#1085#1072
      ImageIndex = 1
      ShortCut = 27
      OnExecute = ActionsExecute
    end
  end
  object ImageList: TImageList
    Left = 420
    Top = 120
  end
end
