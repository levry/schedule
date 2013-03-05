object frmTeachers: TfrmTeachers
  Left = 191
  Top = 107
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1080
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 26
    AutoSize = True
    BorderWidth = 1
    Caption = 'ToolBar1'
    EdgeBorders = []
    Flat = True
    Images = dmMain.ImageBtnList
    TabOrder = 0
    object btnNewTeacher: TToolButton
      Tag = 1
      Left = 0
      Top = 0
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1086#1075#1086' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1103
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      ImageIndex = 3
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object btnEditTeacher: TToolButton
      Tag = 3
      Left = 23
      Top = 0
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080' '#1086' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1077
      Caption = 'btnEditTeacher'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object btnDelTeacher: TToolButton
      Tag = 2
      Left = 46
      Top = 0
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1077#1075#1086' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1103' '#1080#1079' '#1073#1072#1079#1099
      Caption = 'btnDelTeacher'
      ImageIndex = 5
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object btnPreferTeacher: TToolButton
      Tag = 4
      Left = 69
      Top = 0
      Hint = #1055#1088#1086#1089#1084#1086#1090#1088' '#1087#1088#1077#1076#1087#1086#1095#1090#1077#1085#1080#1081' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1103
      Caption = 'btnPreferTeacher'
      ImageIndex = 6
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object ToolButton1: TToolButton
      Left = 92
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object btnUpdate: TToolButton
      Tag = 5
      Left = 100
      Top = 0
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 24
      ParentShowHint = False
      ShowHint = True
      OnClick = OnBtnsClick
    end
    object Label1: TLabel
      Left = 123
      Top = 0
      Width = 80
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1050#1072#1092#1077#1076#1088#1072': '
      Layout = tlCenter
    end
    object cbKafedra: TComboBox
      Left = 203
      Top = 0
      Width = 250
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnChange = cbKafedraChange
      OnDrawItem = cbKafedraDrawItem
    end
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 26
    Width = 688
    Height = 427
    Align = alClient
    DataSource = DataSource
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnEditButtonClick = DBGridEditButtonClick
    Columns = <
      item
        Expanded = False
        FieldName = 'tName'
        Title.Caption = #1060#1072#1084#1080#1083#1080#1103' *'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Name'
        Width = 108
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Partname'
        Width = 124
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Initials'
        Title.Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' *'
        Width = 127
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'pid'
        ReadOnly = True
        Title.Caption = #1047#1074#1072#1085#1080#1077' *'
        Width = 98
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'kid'
        ReadOnly = True
        Title.Caption = #1050#1072#1092#1077#1076#1088#1072' *'
        Width = 156
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'BDay'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Adress'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Phone'
        Visible = True
      end>
  end
  object DataSet: TADODataSet
    Connection = dmMain.Connection
    CursorType = ctStatic
    Parameters = <>
    Left = 570
    Top = 35
    object DataSettid: TLargeintField
      FieldName = 'tid'
      ReadOnly = True
      Visible = False
    end
    object DataSetkid: TLargeintField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      FieldName = 'kid'
      OnGetText = DataSetkidGetText
    end
    object DataSetpid: TIntegerField
      DisplayLabel = #1047#1074#1072#1085#1080#1077
      FieldName = 'pid'
      OnGetText = DataSetpidGetText
    end
    object DataSettName: TStringField
      DisplayLabel = #1060#1072#1084#1080#1083#1080#1103
      FieldName = 'tName'
      Size = 50
    end
    object DataSetName: TStringField
      DisplayLabel = #1048#1084#1103
      FieldName = 'Name'
      Size = 50
    end
    object DataSetPartname: TStringField
      DisplayLabel = #1054#1090#1095#1077#1089#1090#1074#1086
      FieldName = 'Partname'
      Size = 50
    end
    object DataSetInitials: TStringField
      DisplayLabel = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100
      FieldName = 'Initials'
      Size = 50
    end
    object DataSetBDay: TDateTimeField
      DisplayLabel = #1044#1077#1085#1100' '#1088#1086#1078#1076#1077#1085#1080#1103
      FieldName = 'BDay'
      EditMask = '!99/99/00;1;_'
    end
    object DataSetAdress: TStringField
      DisplayLabel = #1040#1076#1088#1077#1089
      FieldName = 'Adress'
      Size = 100
    end
    object DataSetPhone: TStringField
      DisplayLabel = #1058#1077#1083#1077#1092#1086#1085
      FieldName = 'Phone'
    end
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 635
    Top = 35
  end
end
