object frmSchedule: TfrmSchedule
  Left = 328
  Top = 224
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077
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
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 22
    AutoSize = True
    Caption = 'ToolBar'
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnToggleParity: TToolButton
      Left = 0
      Top = 0
      Action = actToggleParity
      ParentShowHint = False
      ShowHint = True
    end
    object btnShowEditor: TToolButton
      Left = 23
      Top = 0
      Action = actShowEditor
      ParentShowHint = False
      ShowHint = True
    end
    object btnDoublePair: TToolButton
      Left = 46
      Top = 0
      Action = actDoublePair
    end
    object btnExecWorkplan: TToolButton
      Left = 69
      Top = 0
      Action = actExecWorkplan
      ParentShowHint = False
      ShowHint = True
    end
    object btnSeparator1: TToolButton
      Left = 92
      Top = 0
      Width = 8
      Caption = 'btnSeparator1'
      ImageIndex = 13
      ParentShowHint = False
      ShowHint = True
      Style = tbsSeparator
    end
    object btnAddGrp: TToolButton
      Left = 100
      Top = 0
      Action = actAddGroup
      ParentShowHint = False
      ShowHint = True
    end
    object btnDeleteGrpList: TToolButton
      Left = 123
      Top = 0
      Action = actDeleteGrpList
      ParentShowHint = False
      ShowHint = True
    end
    object btnSeparator2: TToolButton
      Left = 146
      Top = 0
      Width = 8
      Caption = 'btnSeparator2'
      ImageIndex = 19
      ParentShowHint = False
      ShowHint = True
      Style = tbsSeparator
    end
    object btnUpdateTable: TToolButton
      Left = 154
      Top = 0
      Action = actUpdateTable
      ParentShowHint = False
      ShowHint = True
    end
    object btnExport: TToolButton
      Left = 177
      Top = 0
      Action = actExportTable
      DropdownMenu = ExportMenu
      ParentShowHint = False
      ShowHint = True
      Style = tbsDropDown
    end
  end
  object DayTabControl: TTabControl
    Left = 0
    Top = 22
    Width = 688
    Height = 431
    Align = alClient
    MultiLine = True
    TabOrder = 1
    TabPosition = tpLeft
    Tabs.Strings = (
      #1055#1086#1085#1077#1076#1077#1083#1100#1085#1080#1082
      #1042#1090#1086#1088#1085#1080#1082
      #1057#1088#1077#1076#1072
      #1063#1077#1090#1074#1077#1088#1075
      #1055#1103#1090#1085#1080#1094#1072
      #1057#1091#1073#1073#1086#1090#1072)
    TabIndex = 0
    TabStop = False
    OnChange = DayTabControlChange
    object sGrid: TAdvStringGrid
      Left = 23
      Top = 4
      Width = 661
      Height = 423
      Cursor = crDefault
      Align = alClient
      ColCount = 3
      DefaultColWidth = 170
      DefaultRowHeight = 18
      FixedCols = 2
      RowCount = 43
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColMoving]
      ParentFont = False
      ParentShowHint = False
      PopupMenu = PopupMenu
      ScrollBars = ssBoth
      ShowHint = True
      TabOrder = 0
      OnDragDrop = sGridDragDrop
      OnDragOver = sGridDragOver
      OnSelectCell = sGridSelectCell
      OnGetDisplText = sGridGetDisplText
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      Bands.PrimaryColor = clCream
      Bands.PrimaryLength = 7
      Bands.SecondaryLength = 7
      OnDblClickCell = sGridDblClickCell
      Look = glSoft
      SearchFooter.FindNextCaption = 'Find next'
      SearchFooter.FindPrevCaption = 'Find previous'
      SearchFooter.HighLightCaption = 'Highlight'
      SearchFooter.HintClose = 'Close'
      SearchFooter.HintFindNext = 'Find next occurence'
      SearchFooter.HintFindPrev = 'Find previous occurence'
      SearchFooter.HintHighlight = 'Highlight occurences'
      SearchFooter.MatchCaseCaption = 'Match case'
      PrintSettings.DateFormat = 'dd/mm/yyyy'
      PrintSettings.Font.Charset = DEFAULT_CHARSET
      PrintSettings.Font.Color = clWindowText
      PrintSettings.Font.Height = -11
      PrintSettings.Font.Name = 'MS Sans Serif'
      PrintSettings.Font.Style = []
      PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
      PrintSettings.FixedFont.Color = clWindowText
      PrintSettings.FixedFont.Height = -11
      PrintSettings.FixedFont.Name = 'MS Sans Serif'
      PrintSettings.FixedFont.Style = []
      PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
      PrintSettings.HeaderFont.Color = clWindowText
      PrintSettings.HeaderFont.Height = -11
      PrintSettings.HeaderFont.Name = 'MS Sans Serif'
      PrintSettings.HeaderFont.Style = []
      PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
      PrintSettings.FooterFont.Color = clWindowText
      PrintSettings.FooterFont.Height = -11
      PrintSettings.FooterFont.Name = 'MS Sans Serif'
      PrintSettings.FooterFont.Style = []
      PrintSettings.PageNumSep = '/'
      CellNode.TreeColor = clSilver
      MouseActions.SelectOnRightClick = True
      MouseActions.WheelAction = waScroll
      ScrollWidth = 16
      FixedColWidth = 50
      FixedRowHeight = 18
      FixedFont.Charset = DEFAULT_CHARSET
      FixedFont.Color = clWindowText
      FixedFont.Height = -11
      FixedFont.Name = 'Tahoma'
      FixedFont.Style = [fsBold]
      FloatFormat = '%.2f'
      WordWrap = False
      Filter = <>
      Version = '3.3.0.4'
      ColWidths = (
        50
        50
        170)
      RowHeights = (
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18
        18)
    end
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 495
    Top = 71
    object actShowEditor: TAction
      Tag = 1
      Category = 'Schedule'
      Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1087#1072#1088#1099
      Hint = #1056#1077#1076#1072#1082#1090#1086#1088' '#1087#1072#1088#1099'|'#1042#1099#1079#1086#1074' '#1088#1077#1076#1072#1082#1090#1086#1088#1072' '#1087#1072#1088#1099
      ImageIndex = 14
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actToggleParity: TAction
      Tag = 2
      Category = 'Schedule'
      Caption = #1063#1077#1090#1085#1086#1089#1090#1100' '#1085#1077#1076#1077#1083#1080
      Hint = #1063#1077#1090#1085#1086#1089#1090#1100' '#1085#1077#1076#1077#1083#1080'|'#1048#1079#1084#1077#1085#1080#1090#1100' '#1095#1077#1090#1085#1086#1089#1090#1100' '#1085#1077#1076#1077#1083#1080
      ImageIndex = 15
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actAddGroup: TAction
      Tag = 3
      Category = 'Schedule'
      Caption = #1044#1086#1073#1072#1083#1077#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091'|'#1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
      ImageIndex = 20
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actDeleteGrp: TAction
      Tag = 4
      Category = 'Schedule'
      Caption = #1059#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1091
      Hint = #1059#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1091'|'#1059#1073#1088#1072#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
      ImageIndex = 21
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actDeleteGrpList: TAction
      Tag = 5
      Category = 'Schedule'
      Caption = #1059#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1099
      Hint = #1059#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1099'|'#1059#1073#1088#1072#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1075#1088#1091#1087#1087
      ImageIndex = 21
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdateTable: TAction
      Tag = 6
      Category = 'Schedule'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100'|'#1054#1073#1085#1086#1074#1080#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077
      ImageIndex = 24
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actExportTable: TAction
      Tag = 7
      Category = 'Schedule'
      Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1079#1072#1085#1103#1090#1080#1081
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103'|'#1069#1082#1089#1087#1086#1088#1090' '#1089#1077#1090#1082#1080' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103' '#1079#1072#1085#1103#1090#1080#1081
      ImageIndex = 25
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actExecWorkplan: TAction
      Tag = 8
      Category = 'Schedule'
      Caption = #1048#1089#1087#1086#1083#1085#1077#1085#1080#1077
      Hint = #1048#1089#1087#1086#1083#1085#1077#1085#1080#1077'|'#1048#1089#1087#1086#1083#1085#1077#1085#1080#1077' '#1088#1072#1073#1086#1095#1077#1075#1086' '#1087#1083#1072#1085#1072
      ImageIndex = 17
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actDoublePair: TAction
      Tag = 9
      Category = 'Schedule'
      Caption = #1044#1074#1086#1081#1085#1072#1103' '#1087#1072#1088#1072
      Hint = #1044#1074#1086#1081#1085#1072#1103' '#1087#1072#1088#1072'|'#1057#1076#1077#1083#1072#1090#1100' '#1076#1074#1086#1081#1085#1091#1102' '#1087#1072#1088#1091
      ImageIndex = 16
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actExportNotRes: TAction
      Tag = 10
      Category = 'Schedule'
      Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1074#1085#1077#1072#1091#1076#1080#1090#1086#1088#1085#1099#1093' '#1079#1072#1085#1103#1090#1080#1081
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103' '#1074#1085#1077#1072#1091#1076#1080#1090#1086#1088#1085#1099#1093' '#1079#1072#1085#1103#1090#1080#1081
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object PopupMenu: TPopupMenu
    Images = dmMain.ImageBtnList
    Left = 495
    Top = 126
    object mnuShowEditor: TMenuItem
      Action = actShowEditor
    end
    object mnuToggleParity: TMenuItem
      Action = actToggleParity
    end
    object mnuDoublePair: TMenuItem
      Action = actDoublePair
    end
    object mnuExecWorkplan: TMenuItem
      Action = actExecWorkplan
    end
    object mnuDivider: TMenuItem
      Caption = '-'
    end
    object mnuDeleteGroup: TMenuItem
      Action = actDeleteGrp
    end
  end
  object ExportMenu: TPopupMenu
    Images = dmMain.ImageBtnList
    Left = 495
    Top = 180
    object N1: TMenuItem
      Action = actExportTable
    end
    object N2: TMenuItem
      Action = actExportNotRes
    end
  end
end
