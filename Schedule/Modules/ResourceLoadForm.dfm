object frmResLoad: TfrmResLoad
  Left = 315
  Top = 175
  Width = 696
  Height = 480
  Caption = #1047#1072#1075#1088#1091#1079#1082#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnClick = ActionsExecute
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 493
    Top = 22
    Width = 5
    Height = 431
    Align = alRight
  end
  object ListPanel: TPanel
    Left = 498
    Top = 22
    Width = 190
    Height = 431
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      190
      431)
    object cbKafedra: TComboBox
      Left = 0
      Top = 0
      Width = 190
      Height = 22
      Style = csOwnerDrawFixed
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 16
      TabOrder = 0
      OnChange = cbKafedraChange
      OnDrawItem = cbKafedraDrawItem
    end
    object lbResList: TCheckListBox
      Left = 0
      Top = 25
      Width = 190
      Height = 406
      OnClickCheck = ResListClickCheck
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 16
      Style = lbOwnerDrawFixed
      TabOrder = 1
      OnDrawItem = lbResListDrawItem
      OnKeyUp = lbResListKeyUp
    end
  end
  object DBGridEh: TDBGridEh
    Left = 0
    Top = 22
    Width = 493
    Height = 431
    Align = alClient
    DataSource = DataSource
    EvenRowColor = 16250871
    Flat = True
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'MS Sans Serif'
    FooterFont.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        EditButtons = <>
        FieldName = 'ResID'
        Footers = <>
        Width = 50
      end
      item
        EditButtons = <>
        FieldName = 'ResName'
        Footers = <>
        Width = 120
      end
      item
        EditButtons = <>
        FieldName = 'Division'
        Footers = <>
        Width = 180
      end
      item
        EditButtons = <>
        FieldName = 'Hours'
        Footers = <>
        Width = 100
      end>
  end
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
    TabOrder = 2
    object btnLoadDelete: TToolButton
      Left = 0
      Top = 0
      Action = actLoadDelete
    end
    object btnLoadDeleteAll: TToolButton
      Left = 23
      Top = 0
      Action = actLoadDeleteAll
    end
    object btnLoadExport: TToolButton
      Left = 46
      Top = 0
      Action = actLoadExport
    end
  end
  object DataSet: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <>
    IndexDefs = <>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = False
    SavedCompletely = False
    FilterOptions = []
    Version = '5.50'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    Left = 360
    Top = 55
    object DataSet_ResID: TLargeintField
      DisplayLabel = 'ID'
      FieldName = 'ResID'
    end
    object DataSet_ResName: TStringField
      DisplayLabel = #1053#1072#1079#1074#1072#1085#1080#1077
      FieldName = 'ResName'
      Size = 10
    end
    object DataSet_Division: TStringField
      DisplayLabel = #1055#1086#1076#1088#1072#1079#1076#1077#1083#1077#1085#1080#1077
      FieldName = 'Division'
      Size = 100
    end
    object DataSet_Hours: TIntegerField
      DisplayLabel = #1047#1072#1075#1088#1091#1079#1082#1072' ('#1095#1072#1089'/'#1085#1077#1076')'
      FieldName = 'Hours'
    end
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 420
    Top = 55
  end
  object ActionList: TActionList
    Images = dmMain.ImageBtnList
    Left = 480
    Top = 55
    object actLoadDelete: TAction
      Tag = 1
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Hint = #1059#1076#1072#1083#1080#1090#1100
      ImageIndex = 40
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actLoadDeleteAll: TAction
      Tag = 2
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077
      ImageIndex = 41
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actLoadExport: TAction
      Tag = 3
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093'|'#1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093' '#1074' '#1092#1086#1088#1084#1072#1090' Excel'
      ImageIndex = 25
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel file|*.xls|Any file|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 540
    Top = 55
  end
end
