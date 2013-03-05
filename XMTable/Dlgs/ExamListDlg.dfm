object frmExamListDlg: TfrmExamListDlg
  Left = 244
  Top = 134
  Width = 516
  Height = 298
  BorderStyle = bsSizeToolWin
  Caption = 'frmExamListDlg'
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
    Width = 508
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
    object ToolButton1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object TimePicker: TDateTimePicker
      Left = 54
      Top = 0
      Width = 100
      Height = 22
      Date = 38845.416666666660000000
      Format = 'HH:mm'
      Time = 38845.416666666660000000
      Kind = dtkTime
      TabOrder = 0
      OnChange = TimePickerChange
    end
    object ToolButton3: TToolButton
      Left = 154
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnUpdate: TToolButton
      Left = 162
      Top = 0
      Action = actUpdate
    end
  end
  object vstGrid: TVirtualStringTree
    Left = 0
    Top = 22
    Width = 508
    Height = 228
    Align = alClient
    Header.AutoSizeIndex = 4
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Images = ImageList
    Header.MainColumn = 4
    Header.Options = [hoShowHint, hoShowImages, hoVisible, hoAutoSpring]
    Header.Style = hsFlatButtons
    Images = ImageList
    ParentBackground = False
    ParentShowHint = False
    ScrollBarOptions.ScrollBars = ssNone
    ShowHint = True
    TabOrder = 1
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnBeforeItemErase = vstGridBeforeItemErase
    OnColumnClick = vstGridColumnClick
    OnDblClick = vstGridDblClick
    OnGetText = vstGridGetText
    OnGetImageIndex = vstGridGetImageIndex
    Columns = <
      item
        ImageIndex = 3
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 0
        Width = 30
        WideHint = #1057#1086#1073#1099#1090#1080#1077' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1086
      end
      item
        ImageIndex = 4
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 1
        Width = 30
        WideHint = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1103
      end
      item
        ImageIndex = 5
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 2
        Width = 30
        WideHint = #1053#1072#1088#1091#1096#1077#1085#1080#1077' '#1087#1086#1088#1103#1076#1082#1072
      end
      item
        ImageIndex = 6
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 3
        Width = 30
        WideHint = #1055#1086#1076#1075#1088#1091#1087#1087#1072
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible, coAutoSpring]
        Position = 4
        Width = 250
        WideText = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        WideHint = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coVisible]
        Position = 5
        Width = 134
        WideText = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
        WideHint = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100'('#1080')'
      end>
  end
  object TabSet: TTabSet
    Left = 0
    Top = 250
    Width = 508
    Height = 21
    Align = alBottom
    AutoScroll = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    SoftTop = True
    Tabs.Strings = (
      #1069#1082#1079#1072#1084#1077#1085
      #1050#1086#1085#1089#1091#1083#1100#1090#1072#1094#1080#1103)
    TabIndex = 0
    OnChange = TabSetChange
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 390
    Top = 55
    object actSelect: TAction
      Tag = 1
      Caption = #1042#1099#1073#1088#1072#1090#1100
      Hint = #1042#1099#1073#1088#1072#1090#1100
      ImageIndex = 0
      ShortCut = 13
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actCancel: TAction
      Tag = 2
      Caption = #1054#1090#1084#1077#1085#1072
      Hint = #1054#1090#1084#1077#1085#1072
      ImageIndex = 1
      ShortCut = 27
      OnExecute = ActionsExecute
    end
    object actUpdate: TAction
      Tag = -1
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 2
      ShortCut = 116
      OnExecute = ActionsExecute
    end
  end
  object ImageList: TImageList
    Left = 390
    Top = 110
  end
end
