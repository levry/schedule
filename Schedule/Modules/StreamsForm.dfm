object frmStreams: TfrmStreams
  Left = 312
  Top = 133
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1087#1086#1090#1086#1082#1072#1084#1080
  ClientHeight = 453
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tcType: TTabControl
    Left = 0
    Top = 24
    Width = 688
    Height = 429
    Align = alClient
    MultiLine = True
    PopupMenu = TabMenu
    TabOrder = 1
    TabPosition = tpRight
    Tabs.Strings = (
      #1051#1077#1082#1094#1080#1080
      #1055#1088#1072#1082#1090#1080#1082#1080
      #1051#1072#1073'. '#1079#1072#1085#1103#1090#1080#1103)
    TabIndex = 0
    OnChange = tcTypeChange
    object Splitter: TSplitter
      Left = 4
      Top = 204
      Width = 661
      Height = 5
      Cursor = crVSplit
      Align = alTop
    end
    object PanelStream: TPanel
      Left = 4
      Top = 4
      Width = 661
      Height = 200
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object LabelStream: TLabel
        Left = 0
        Top = 0
        Width = 661
        Height = 18
        Align = alTop
        AutoSize = False
        Caption = '  '#1055#1086#1090#1086#1082#1080
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
      object vstStreams: TVirtualStringTree
        Tag = 2
        Left = 0
        Top = 18
        Width = 661
        Height = 182
        Align = alClient
        BorderStyle = bsNone
        DragOperations = [doMove]
        DragType = dtVCL
        EditDelay = 300
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'MS Sans Serif'
        Header.Font.Style = []
        Header.Options = [hoColumnResize, hoShowHint, hoVisible]
        Header.Style = hsFlatButtons
        ParentBackground = False
        PopupMenu = StreamMenu
        TabOrder = 0
        TreeOptions.AutoOptions = [toAutoDropExpand, toAutoDeleteMovedNodes]
        TreeOptions.MiscOptions = [toEditable, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
        TreeOptions.PaintOptions = [toShowButtons, toShowRoot, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
        OnCreateEditor = vtCreateEditor
        OnDragOver = vstStreamsDragOver
        OnDragDrop = vstStreamsDragDrop
        OnEditing = vstEditing
        OnGetText = vstStreamsGetText
        Columns = <
          item
            Position = 0
            Width = 100
            WideText = #1055#1086#1090#1086#1082
          end
          item
            Position = 1
            Width = 170
            WideText = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
            WideHint = #1053#1072#1079#1074#1072#1085#1080#1077' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1099
          end
          item
            Position = 2
            Width = 70
            WideText = #1053#1072#1075#1088#1091#1079#1082#1072
          end>
      end
    end
    object PanelDeclare: TPanel
      Left = 4
      Top = 209
      Width = 661
      Height = 216
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object LabelDeclare: TLabel
        Left = 0
        Top = 0
        Width = 661
        Height = 18
        Align = alTop
        AutoSize = False
        Caption = '  '#1057#1074#1086#1073#1086#1076#1085#1099#1077' '#1075#1088#1091#1087#1087#1099
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
      object vstDeclares: TVirtualStringTree
        Tag = 1
        Left = 0
        Top = 18
        Width = 661
        Height = 198
        Align = alClient
        BorderStyle = bsNone
        DragMode = dmAutomatic
        DragOperations = [doMove]
        DragType = dtVCL
        EditDelay = 300
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'MS Sans Serif'
        Header.Font.Style = []
        Header.Options = [hoColumnResize, hoShowHint, hoVisible]
        Header.Style = hsFlatButtons
        ParentBackground = False
        PopupMenu = StreamMenu
        TabOrder = 0
        TreeOptions.AutoOptions = [toAutoDeleteMovedNodes]
        TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
        TreeOptions.PaintOptions = [toShowButtons, toShowRoot, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
        OnGetText = vstDeclaresGetText
        Columns = <
          item
            Position = 0
            Width = 100
            WideText = #1043#1088#1091#1087#1087#1072
            WideHint = #1053#1072#1079#1074#1072#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
          end
          item
            Position = 1
            Width = 170
            WideText = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
          end
          item
            Position = 2
            Width = 70
            WideText = #1053#1072#1075#1088#1091#1079#1082#1072
            WideHint = #1050#1086#1083'-'#1074#1086' '#1095#1072#1089#1086#1074' '#1074' '#1085#1077#1076#1077#1083#1102
          end>
      end
    end
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 24
    AutoSize = True
    EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
    EdgeInner = esNone
    EdgeOuter = esRaised
    Flat = True
    Images = dmMain.ImageBtnList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnNewStrm: TToolButton
      Left = 0
      Top = 0
      Action = actNewStrm
    end
    object btnDeleteStrm: TToolButton
      Left = 23
      Top = 0
      Action = actDeleteStrm
    end
    object btnDeleteGroup: TToolButton
      Left = 46
      Top = 0
      Action = actDeleteGroup
    end
    object btnAddGroup: TToolButton
      Left = 69
      Top = 0
      Action = actAddGroup
    end
    object ToolButton1: TToolButton
      Left = 92
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnUpdate: TToolButton
      Left = 100
      Top = 0
      Action = actUpdate
    end
    object btnView: TToolButton
      Left = 123
      Top = 0
      Caption = 'btnView'
      DropdownMenu = ViewMenu
      ParentShowHint = False
      ShowHint = False
      Style = tbsDropDown
    end
    object ToolButton2: TToolButton
      Left = 159
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 0
      Style = tbsSeparator
    end
  end
  object TabMenu: TPopupMenu
    Left = 585
    Top = 54
    object mnuTop: TMenuItem
      Tag = 1
      Caption = 'Top'
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuClick
    end
    object mnuLeft: TMenuItem
      Tag = 2
      Caption = 'Left'
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuClick
    end
    object mnuRight: TMenuItem
      Tag = 3
      Caption = 'Right'
      Checked = True
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuClick
    end
    object mnuBottom: TMenuItem
      Tag = 4
      Caption = 'Bottom'
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuClick
    end
  end
  object ViewMenu: TPopupMenu
    Left = 585
    Top = 100
    object mnuVertical: TMenuItem
      Tag = 1
      Caption = 'Vertical'
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuViewClick
    end
    object mnuHorizontal: TMenuItem
      Tag = 2
      Caption = 'Horizontal'
      Checked = True
      GroupIndex = 3
      RadioItem = True
      OnClick = mnuViewClick
    end
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 514
    Top = 53
    object actNewStrm: TAction
      Tag = 1
      Category = 'Stream'
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1090#1086#1082
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1090#1086#1082
      ImageIndex = 0
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actDeleteStrm: TAction
      Tag = 2
      Category = 'Stream'
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1090#1086#1082
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1090#1086#1082
      ImageIndex = 2
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actAddGroup: TAction
      Tag = 3
      Category = 'Stream'
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
      ImageIndex = 1
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actDeleteGroup: TAction
      Tag = 4
      Category = 'Stream'
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091' '#1080#1079' '#1087#1086#1090#1086#1082#1072
      ImageIndex = 2
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdate: TAction
      Tag = -1
      Category = 'Stream'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 24
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object StreamMenu: TPopupMenu
    Images = dmMain.ImageBtnList
    Left = 479
    Top = 128
    object mnuNewStrm: TMenuItem
      Action = actNewStrm
    end
    object mnuAddGroup: TMenuItem
      Action = actAddGroup
    end
    object mnuDeleteGroup: TMenuItem
      Action = actDeleteGroup
    end
    object mnuDeleteStrm: TMenuItem
      Action = actDeleteStrm
    end
  end
end
