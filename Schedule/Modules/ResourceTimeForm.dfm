object frmResTime: TfrmResTime
  Left = 328
  Top = 220
  BorderIcons = []
  BorderStyle = bsNone
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
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnTimeShowTeacher: TToolButton
      Left = 0
      Top = 0
      Action = actTimeShowList
      Style = tbsCheck
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnTimeDeleteItem: TToolButton
      Left = 31
      Top = 0
      Action = actTimeDeleteItem
    end
    object btnTimeDeleteAll: TToolButton
      Left = 54
      Top = 0
      Action = actTimeDeleteAll
    end
    object btnTimeExport: TToolButton
      Left = 77
      Top = 0
      Action = actTimeExport
    end
  end
  object DayTabControl: TTabControl
    Left = 0
    Top = 22
    Width = 688
    Height = 431
    Align = alClient
    MultiLine = True
    TabOrder = 0
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
    object Splitter: TSplitter
      Left = 494
      Top = 4
      Width = 5
      Height = 423
      Align = alRight
    end
    object Grid: TAdvStringGrid
      Left = 23
      Top = 4
      Width = 471
      Height = 423
      Cursor = crDefault
      Align = alClient
      ColCount = 3
      Ctl3D = True
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
      ParentCtl3D = False
      ParentFont = False
      ParentShowHint = False
      ScrollBars = ssBoth
      ShowHint = True
      TabOrder = 0
      OnSelectCell = GridSelectCell
      OnGetDisplText = GridGetDisplText
      ActiveCellFont.Charset = DEFAULT_CHARSET
      ActiveCellFont.Color = clWindowText
      ActiveCellFont.Height = -11
      ActiveCellFont.Name = 'Tahoma'
      ActiveCellFont.Style = [fsBold]
      Bands.Active = True
      Bands.PrimaryColor = 16250871
      Bands.PrimaryLength = 7
      Bands.SecondaryLength = 7
      OnGridHint = GridGridHint
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
    object ListPanel: TPanel
      Left = 499
      Top = 4
      Width = 185
      Height = 423
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        185
        423)
      object lbResList: TCheckListBox
        Left = 0
        Top = 50
        Width = 185
        Height = 373
        OnClickCheck = ResListClickCheck
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 16
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnDblClick = ResListDblClick
        OnDrawItem = ResListDrawItem
        OnKeyUp = lbResListKeyUp
      end
      object cbKafedra: TComboBox
        Left = 0
        Top = 26
        Width = 185
        Height = 22
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 16
        TabOrder = 1
        OnChange = cbKafedraChange
        OnDrawItem = cbKafedraDrawItem
      end
      object ListToolBar: TToolBar
        Left = 0
        Top = 0
        Width = 185
        Height = 22
        AutoSize = True
        EdgeBorders = []
        Flat = True
        Images = dmMain.ImageBtnList
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        object btnListFacultyKaf: TToolButton
          Left = 0
          Top = 0
          Action = actListFacultyKaf
          Style = tbsCheck
        end
        object btnListPerformKaf: TToolButton
          Left = 23
          Top = 0
          Action = actListPerformKaf
          Style = tbsCheck
        end
      end
    end
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 605
    Top = 49
    object actTimeShowList: TAction
      Tag = -1
      Caption = #1057#1087#1080#1089#1086#1082
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100'/'#1091#1073#1088#1072#1090#1100' '#1089#1087#1080#1089#1086#1082
      ImageIndex = 30
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
    object actTimeDeleteItem: TAction
      Tag = 1
      Caption = #1059#1073#1088#1072#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077
      Hint = #1059#1073#1088#1072#1090#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1077
      ImageIndex = 32
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
    object actTimeDeleteAll: TAction
      Tag = 3
      Caption = #1059#1073#1088#1072#1090#1100' '#1074#1089#1077
      Hint = #1059#1073#1088#1072#1090#1100' '#1074#1089#1077
      ImageIndex = 33
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
    object actTimeExport: TAction
      Tag = 2
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103
      ImageIndex = 25
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
    object actListFacultyKaf: TAction
      Tag = -2
      Hint = #1050#1072#1092#1077#1076#1088#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      ImageIndex = 39
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
    object actListPerformKaf: TAction
      Tag = -3
      Caption = 'actListPerformKaf'
      Hint = #1050#1072#1092#1077#1076#1088#1099'-'#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1080
      ImageIndex = 38
      OnExecute = ActionExecute
      OnUpdate = ActionUpdate
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel file|*.xls|Any file|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 605
    Top = 100
  end
end
