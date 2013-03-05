object frmAuditory: TfrmAuditory
  Left = 191
  Top = 107
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1040#1091#1076#1080#1090#1086#1088#1080#1080
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
  object DBGrid: TDBGrid
    Left = 0
    Top = 26
    Width = 688
    Height = 427
    Align = alClient
    DataSource = DataSource
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnEditButtonClick = DBGridEditButtonClick
    Columns = <
      item
        Expanded = False
        FieldName = 'aName'
        Width = 106
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'kid'
        ReadOnly = True
        Width = 214
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Capacity'
        Width = 78
        Visible = True
      end>
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 26
    AutoSize = True
    BorderWidth = 1
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    TabOrder = 1
    object btnDelAud: TToolButton
      Tag = 1
      Left = 0
      Top = 0
      Hint = #1059#1076#1072#1083#1077#1085#1080#1077' '#1072#1091#1076#1080#1090#1086#1088#1080#1080
      Caption = 'btnDelAud'
      ImageIndex = 7
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object btnPreferAudit: TToolButton
      Tag = 2
      Left = 23
      Top = 0
      Hint = #1055#1088#1086#1089#1084#1086#1090#1088' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1081' '#1076#1083#1103' '#1072#1091#1076#1080#1090#1086#1088#1080#1080
      Caption = 'btnPreferAudit'
      ImageIndex = 8
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object ToolButton1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object btnUpdate: TToolButton
      Tag = 3
      Left = 54
      Top = 0
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 24
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object Label1: TLabel
      Left = 77
      Top = 0
      Width = 90
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1060#1072#1082#1091#1083#1100#1090#1077#1090': '
      Layout = tlCenter
    end
    object cbFaculty: TComboBox
      Left = 167
      Top = 0
      Width = 250
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnChange = cbFacultyChange
      OnDrawItem = cbFacultyDrawItem
    end
  end
  object AuditorySet: TADODataSet
    Connection = dmMain.Connection
    CursorType = ctStatic
    BeforePost = AuditorySetNewRecord
    Parameters = <>
    Left = 535
    Top = 50
    object AuditorySetaid: TLargeintField
      DisplayLabel = 'ID'
      FieldName = 'aid'
      ReadOnly = True
    end
    object AuditorySetaName: TStringField
      DisplayLabel = #1053#1072#1079#1074#1072#1085#1080#1077
      FieldName = 'aName'
      Size = 10
    end
    object AuditorySetkid: TLargeintField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      FieldName = 'kid'
      OnGetText = AuditorySetkidGetText
    end
    object AuditorySetCapacity: TIntegerField
      DisplayLabel = #1042#1084#1077#1089#1090#1080#1084#1086#1089#1090#1100
      FieldName = 'Capacity'
    end
    object AuditorySetfid: TIntegerField
      DisplayLabel = #1060#1072#1082#1091#1083#1100#1090#1077#1090
      FieldName = 'fid'
    end
  end
  object DataSource: TDataSource
    DataSet = AuditorySet
    Left = 600
    Top = 50
  end
end
