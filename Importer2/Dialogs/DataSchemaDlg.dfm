object frmDataSchemaDlg: TfrmDataSchemaDlg
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = #1057#1093#1077#1084#1072
  ClientHeight = 455
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    400
    455)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 242
    Top = 427
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 322
    Top = 427
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object DBGrid: TDBGridEh
    Left = 5
    Top = 45
    Width = 391
    Height = 373
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoFitColWidths = True
    DataSource = DataSource
    Flat = True
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'MS Sans Serif'
    FooterFont.Style = []
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        EditButtons = <>
        FieldName = 'title'
        Footers = <>
        ReadOnly = True
        Title.Caption = #1044#1072#1085#1085#1099#1077
      end
      item
        AutoFitColWidth = False
        EditButtons = <>
        FieldName = 'row'
        Footers = <>
        Title.Caption = #1057#1090#1088#1086#1082#1072
        OnGetCellParams = DBGridColumns1GetCellParams
      end
      item
        AutoFitColWidth = False
        EditButtons = <>
        FieldName = 'coll'
        Footers = <>
        Title.Caption = #1050#1086#1083#1086#1085#1082#1072
      end>
  end
  object InfoPanel: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 41
    Align = alTop
    Color = clWhite
    TabOrder = 3
    object InfoLabel: TLabel
      Left = 65
      Top = 5
      Width = 85
      Height = 13
      Caption = #1057#1093#1077#1084#1072' '#1076#1072#1085#1085#1099#1093
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 80
      Top = 20
      Width = 237
      Height = 13
      Caption = #1059#1082#1072#1078#1080#1090#1077' '#1103#1095#1077#1081#1082#1080' '#1076#1083#1103' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1102#1097#1080#1093' '#1076#1072#1085#1085#1099#1093
    end
  end
  object btnExport: TButton
    Tag = 2
    Left = 85
    Top = 427
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1069#1082#1089#1087#1086#1088#1090
    TabOrder = 4
    OnClick = btnClick
  end
  object btnImport: TButton
    Tag = 1
    Left = 5
    Top = 427
    Width = 75
    Height = 25
    Caption = #1048#1084#1087#1086#1088#1090
    TabOrder = 5
    OnClick = btnClick
  end
  object SchemaTable: TkbmMemTable
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
    Left = 270
    Top = 70
    object SchemaTable_name: TStringField
      FieldName = 'name'
    end
    object SchemaTable_title: TStringField
      FieldName = 'title'
    end
    object SchemaTable_row: TIntegerField
      FieldName = 'row'
      OnValidate = SchemaTable_rowValidate
    end
    object SchemaTable_coll: TIntegerField
      CustomConstraint = 'x > 0'
      ConstraintErrorMessage = #1047#1085#1072#1095#1077#1085#1080#1077' '#1076#1086#1083#1078#1085#1086' '#1073#1099#1090#1100' '#1087#1086#1083#1086#1078#1080#1090#1077#1083#1100#1085#1099#1084
      FieldName = 'coll'
    end
  end
  object DataSource: TDataSource
    DataSet = SchemaTable
    Left = 345
    Top = 70
  end
end
