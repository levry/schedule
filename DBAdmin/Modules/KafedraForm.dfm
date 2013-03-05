object frmKafedrs: TfrmKafedrs
  Left = 244
  Top = 104
  AutoScroll = False
  Caption = #1050#1072#1092#1077#1076#1088#1099
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
    Top = 22
    Width = 688
    Height = 431
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
        FieldName = 'kid'
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'fid'
        ReadOnly = True
        Width = 220
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'kName'
        Visible = True
      end>
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 22
    EdgeBorders = []
    Flat = True
    TabOrder = 1
    object lFaculty: TLabel
      Left = 0
      Top = 0
      Width = 80
      Height = 22
      AutoSize = False
      Caption = #1060#1072#1082#1091#1083#1100#1090#1077#1090#1099':'
      Layout = tlCenter
    end
    object cbFaculty: TComboBox
      Left = 80
      Top = 0
      Width = 300
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnChange = cbFacultyChange
      OnDrawItem = cbFacultyDrawItem
    end
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 550
    Top = 100
  end
  object DataSet: TADODataSet
    Connection = dmAdmin.Connection
    CursorType = ctStatic
    Parameters = <>
    Left = 470
    Top = 100
    object DataSetkid: TLargeintField
      DisplayLabel = 'ID'
      FieldName = 'kid'
      ReadOnly = True
    end
    object DataSetfid: TIntegerField
      DisplayLabel = #1060#1072#1082#1091#1083#1100#1090#1077#1090
      FieldName = 'fid'
      OnGetText = DataSetfidGetText
    end
    object DataSetkName: TStringField
      DisplayLabel = #1053#1072#1079#1074#1072#1085#1080#1077' '#1082#1072#1092#1077#1076#1088#1099
      DisplayWidth = 50
      FieldName = 'kName'
      Size = 150
    end
  end
end
