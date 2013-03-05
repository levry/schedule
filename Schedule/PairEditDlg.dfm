object frmPairEditDlg: TfrmPairEditDlg
  Left = 244
  Top = 137
  BorderStyle = bsToolWindow
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1087#1072#1088#1099
  ClientHeight = 278
  ClientWidth = 260
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 260
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    TabOrder = 0
    object btnLsnsAdd: TToolButton
      Left = 0
      Top = 0
      Action = actLsnsAdd
    end
    object btnLsnsDelete: TToolButton
      Left = 23
      Top = 0
      Action = actLsnsDelete
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 12
      Style = tbsSeparator
    end
    object btnLsnsEdit: TToolButton
      Left = 54
      Top = 0
      Action = actLsnsEdit
      ParentShowHint = False
      ShowHint = True
    end
  end
  object LsnsGrid: TAdvStringGrid
    Left = 0
    Top = 22
    Width = 260
    Height = 237
    Cursor = crDefault
    Align = alClient
    ColCount = 1
    DefaultColWidth = 197
    DefaultRowHeight = 39
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 1
    OnEndDrag = LsnsGridEndDrag
    OnMouseDown = LsnsGridMouseDown
    OnMouseMove = LsnsGridMouseMove
    OnMouseUp = LsnsGridMouseUp
    OnGetDisplText = LsnsGridGetDisplText
    ActiveCellFont.Charset = DEFAULT_CHARSET
    ActiveCellFont.Color = clWindowText
    ActiveCellFont.Height = -11
    ActiveCellFont.Name = 'Tahoma'
    ActiveCellFont.Style = [fsBold]
    OnRowChanging = LsnsGridRowChanging
    OnCanEditCell = LsnsGridCanEditCell
    OnGetEditorType = LsnsGridGetEditorType
    Look = glStandard
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
    ScrollWidth = 16
    FixedColWidth = 197
    FixedRowHeight = 39
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'Tahoma'
    FixedFont.Style = [fsBold]
    FloatFormat = '%.2f'
    Hovering = True
    Filter = <>
    Version = '3.3.0.4'
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 259
    Width = 260
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 70
      end
      item
        Width = 70
      end>
  end
  object CtrlEditLink: TFormControlEditLink
    Tag = 0
    AutoPopupWidth = False
    EditStyle = esInplace
    PopupWidth = 0
    PopupHeight = 0
    WantKeyLeftRight = False
    WantKeyUpDown = False
    WantKeyHomeEnd = False
    WantKeyPriorNext = False
    WantKeyReturn = False
    WantKeyEscape = False
    OnSetEditorValue = CtrlEditLinkSetEditorValue
    Left = 205
    Top = 90
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 205
    Top = 37
    object actLsnsEdit: TAction
      Tag = 1
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1079#1072#1085#1103#1090#1080#1077
      ImageIndex = 11
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actLsnsAdd: TAction
      Tag = 2
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1079#1072#1085#1103#1090#1080#1077
      ImageIndex = 9
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actLsnsDelete: TAction
      Tag = 3
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1085#1103#1090#1080#1077
      ImageIndex = 10
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
end
