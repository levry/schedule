object frmExamTable: TfrmExamTable
  Left = 244
  Top = 133
  AutoScroll = False
  Caption = #1069#1082#1079#1072#1084#1077#1085#1099
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
    Images = ImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object btnExamAddGrp: TToolButton
      Left = 0
      Top = 0
      Action = actExamAddGroup
    end
    object btnExamDelGroups: TToolButton
      Left = 23
      Top = 0
      Action = actExamDelGroups
    end
    object ToolButton5: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnExamAdd: TToolButton
      Left = 54
      Top = 0
      Action = actExamAdd
    end
    object btnExamDelete: TToolButton
      Left = 77
      Top = 0
      Action = actExamDelete
    end
    object ToolButton3: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnExamLayerAll: TToolButton
      Left = 108
      Top = 0
      Action = actExamLayerAll
      Grouped = True
      Style = tbsCheck
    end
    object btnExamLayerExam: TToolButton
      Left = 131
      Top = 0
      Action = actExamLayerExam
      Grouped = True
      Style = tbsCheck
    end
    object btnExamLayerCons: TToolButton
      Left = 154
      Top = 0
      Action = actExamLayerCons
      Grouped = True
      Style = tbsCheck
    end
    object ToolButton1: TToolButton
      Left = 177
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object btnExamExport: TToolButton
      Left = 185
      Top = 0
      Action = actExamExport
    end
    object btnExamUpdate: TToolButton
      Left = 208
      Top = 0
      Action = acExamUpdate
    end
  end
  object Planner: TPlanner
    Left = 0
    Top = 22
    Width = 688
    Height = 431
    Align = alClient
    AttachementGlyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8888888888700078888888888708880788888888808808808888888880808080
      8888888880808080888888888080808088888888808080808888888880808080
      8888888880808080888888888080808088888888808080808888888888808080
      8888888888808880888888888888000888888888888888888888}
    Caption.Title = 'TPlanner'
    Caption.Font.Charset = DEFAULT_CHARSET
    Caption.Font.Color = clWhite
    Caption.Font.Height = -13
    Caption.Font.Name = 'MS Sans Serif'
    Caption.Font.Style = [fsBold]
    Caption.Visible = False
    DayNames.Strings = (
      'Sun'
      'Mon'
      'Tue'
      'Wed'
      'Thu'
      'Fri'
      'Sat')
    DefaultItem.CaptionBkgTo = clSilver
    DefaultItem.CaptionFont.Charset = DEFAULT_CHARSET
    DefaultItem.CaptionFont.Color = clWindowText
    DefaultItem.CaptionFont.Height = -11
    DefaultItem.CaptionFont.Name = 'MS Sans Serif'
    DefaultItem.CaptionFont.Style = []
    DefaultItem.ColorTo = 16250871
    DefaultItem.Cursor = -1
    DefaultItem.FixedPos = True
    DefaultItem.FixedSize = True
    DefaultItem.Font.Charset = DEFAULT_CHARSET
    DefaultItem.Font.Color = clWindowText
    DefaultItem.Font.Height = -11
    DefaultItem.Font.Name = 'MS Sans Serif'
    DefaultItem.Font.Style = []
    DefaultItem.ItemBegin = 16
    DefaultItem.ItemEnd = 17
    DefaultItem.ItemPos = 0
    DefaultItem.Name = 'PlannerItem0'
    DefaultItem.SelectColor = clWhite
    DefaultItem.SelectColorTo = clInfoBk
    DefaultItem.Shadow = True
    DeleteGlyph.Data = {
      36050000424D3605000000000000360400002800000010000000100000000100
      0800000000000001000000000000000000000001000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
      A6000020400000206000002080000020A0000020C0000020E000004000000040
      20000040400000406000004080000040A0000040C0000040E000006000000060
      20000060400000606000006080000060A0000060C0000060E000008000000080
      20000080400000806000008080000080A0000080C0000080E00000A0000000A0
      200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
      200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
      200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
      20004000400040006000400080004000A0004000C0004000E000402000004020
      20004020400040206000402080004020A0004020C0004020E000404000004040
      20004040400040406000404080004040A0004040C0004040E000406000004060
      20004060400040606000406080004060A0004060C0004060E000408000004080
      20004080400040806000408080004080A0004080C0004080E00040A0000040A0
      200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
      200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
      200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
      20008000400080006000800080008000A0008000C0008000E000802000008020
      20008020400080206000802080008020A0008020C0008020E000804000008040
      20008040400080406000804080008040A0008040C0008040E000806000008060
      20008060400080606000806080008060A0008060C0008060E000808000008080
      20008080400080806000808080008080A0008080C0008080E00080A0000080A0
      200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
      200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
      200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
      2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
      2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
      2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
      2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
      2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
      2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
      2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00D9ED07070707
      0707070707070707ECD9EC5E5E5E5E5E5E5E5E5E5E5E5E5E5DED070D0E161616
      161616160E0E0E0E5E07070D161656561616161616160E0E5E07070D16AF075E
      56561657B7EF0E0E5E07070D56AFF6075F565FAFF6AF160E5E07070D565EAFF6
      075FEFF6AF17160E5E07070D5E5E5EAFF607F6AF161616165E07070D5E5E5E5E
      EFF60756161616165E07070D5E5E5FEFF6EFF6075E1616165E07070D5F5F07F6
      EF5EAFF6075616165E07070D6707F6075E5656AFF60716165E07070DA7AF075F
      5E5E5E5EAFAF56165E07070DA7A7675F5F5E5E5E5E5E56165E07EDAF0D0D0D0D
      0D0D0D0D0D0D0D0D5EECD9ED070707070707070707070707EDD1}
    Display.ActiveEnd = 40
    Display.DisplayScale = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Footer.Captions.Strings = (
      ''
      '')
    Footer.CompletionFormat = '%d%%'
    Footer.Completion.Font.Charset = DEFAULT_CHARSET
    Footer.Completion.Font.Color = clWindowText
    Footer.Completion.Font.Height = -11
    Footer.Completion.Font.Name = 'Arial'
    Footer.Completion.Font.Style = []
    Footer.Font.Charset = DEFAULT_CHARSET
    Footer.Font.Color = clWindowText
    Footer.Font.Height = -11
    Footer.Font.Name = 'MS Sans Serif'
    Footer.Font.Style = []
    GridLeftCol = 0
    GridTopRow = 1
    Header.Captions.Strings = (
      ''
      '')
    Header.CustomGroups = <>
    Header.Height = 60
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clBlack
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.GroupFont.Charset = DEFAULT_CHARSET
    Header.GroupFont.Color = clWindowText
    Header.GroupFont.Height = -11
    Header.GroupFont.Name = 'MS Sans Serif'
    Header.GroupFont.Style = []
    Header.ItemHeight = 0
    Header.TextHeight = 60
    HintPause = 3000
    HTMLOptions.CellFontStyle = []
    HTMLOptions.HeaderFontStyle = []
    HTMLOptions.SidebarFontStyle = []
    InActiveDays.Sat = False
    InplaceEdit = ieNever
    Items = <>
    Mode.Month = 5
    Mode.PeriodStartDay = 3
    Mode.PeriodStartMonth = 5
    Mode.PeriodStartYear = 2006
    Mode.PeriodEndDay = 20
    Mode.PeriodEndMonth = 6
    Mode.PeriodEndYear = 2006
    Mode.PlannerType = plDayPeriod
    Mode.TimeLineStart = 38840.000000000000000000
    Mode.TimeLineNVUBegin = 0
    Mode.TimeLineNVUEnd = 0
    Mode.Year = 2006
    Sidebar.Font.Charset = DEFAULT_CHARSET
    Sidebar.Font.Color = clBlack
    Sidebar.Font.Height = -11
    Sidebar.Font.Name = 'Arial'
    Sidebar.Font.Style = []
    Sidebar.HourFontRatio = 1.800000000000000000
    Sidebar.OccupiedTo = clWhite
    Sidebar.Position = spTop
    Sidebar.RotateOnTop = False
    Sidebar.ShowDayName = False
    PlannerImages = ImageList
    Positions = 1
    PositionProps = <>
    PositionWidth = 80
    PrintOptions.FooterFont.Charset = DEFAULT_CHARSET
    PrintOptions.FooterFont.Color = clWindowText
    PrintOptions.FooterFont.Height = -11
    PrintOptions.FooterFont.Name = 'MS Sans Serif'
    PrintOptions.FooterFont.Style = []
    PrintOptions.HeaderFont.Charset = DEFAULT_CHARSET
    PrintOptions.HeaderFont.Color = clWindowText
    PrintOptions.HeaderFont.Height = -11
    PrintOptions.HeaderFont.Name = 'MS Sans Serif'
    PrintOptions.HeaderFont.Style = []
    SelectRange = False
    URLGlyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888880000800
      0088888808F8F0F8F80888808000000000808880F070888070F0888080000000
      0080880408F8F0F8F80880CCC0000400008874CCC2222C4788887CCCC22226C0
      88887CC822222CC088887C822224642088887C888422C220888877CF8CCCC227
      888887F8F8222208888888776888208888888887777778888888}
    Version = '2.5.0.2'
    OnItemDelete = PlannerItemDelete
    OnItemInsert = PlannerItemInsert
    OnItemHint = PlannerItemHint
    OnPlannerDblClick = PlannerPlannerDblClick
    OnDragOver = PlannerDragOver
    OnDragDrop = PlannerDragDrop
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 590
    Top = 74
    object acExamUpdate: TAction
      Tag = -1
      Category = 'Exam'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 11
      OnExecute = OnActionsExecute
    end
    object actExamAddGroup: TAction
      Tag = 1
      Category = 'Exam'
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
      ImageIndex = 2
      OnExecute = OnActionsExecute
    end
    object actExamDelGroups: TAction
      Tag = 2
      Category = 'Exam'
      Caption = #1059#1073#1088#1072#1090#1100
      Hint = #1059#1073#1088#1072#1090#1100' '#1075#1088#1091#1087#1087#1099
      ImageIndex = 3
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamAdd: TAction
      Tag = 3
      Category = 'Exam'
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100
      ImageIndex = 5
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamDelete: TAction
      Tag = 4
      Category = 'Exam'
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Hint = #1059#1076#1072#1083#1080#1090#1100
      ImageIndex = 6
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamLayerAll: TAction
      Tag = 7
      Category = 'Exam'
      Caption = #1042#1089#1077
      Hint = #1042#1089#1077
      ImageIndex = 8
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamLayerExam: TAction
      Tag = 8
      Category = 'Exam'
      Caption = #1069#1082#1079#1072#1084#1077#1085#1099
      Hint = #1069#1082#1079#1072#1084#1077#1085#1099
      ImageIndex = 9
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamLayerCons: TAction
      Tag = 9
      Category = 'Exam'
      Caption = #1050#1086#1085#1089#1091#1083#1100#1090#1072#1094#1080#1080
      Hint = #1050#1086#1085#1089#1091#1083#1100#1090#1072#1094#1080#1080
      ImageIndex = 10
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
    object actExamExport: TAction
      Tag = 10
      Category = 'Exam'
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103
      ImageIndex = 12
      OnExecute = OnActionsExecute
      OnUpdate = OnActionsUpdate
    end
  end
  object ImageList: TImageList
    Left = 590
    Top = 127
  end
end
