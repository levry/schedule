object frmGroups: TfrmGroups
  Left = 191
  Top = 104
  AutoScroll = False
  Caption = #1043#1088#1091#1087#1087#1099
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
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid: TDBGrid
    Left = 0
    Top = 24
    Width = 688
    Height = 429
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
        FieldName = 'grName'
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'kid'
        ReadOnly = True
        Width = 250
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'studs'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'course'
        PickList.Strings = (
          '1'
          '2'
          '3'
          '4'
          '5')
        Visible = True
      end>
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 24
    AutoSize = True
    EdgeBorders = []
    TabOrder = 1
    object Label1: TLabel
      Left = 0
      Top = 2
      Width = 70
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1050#1072#1092#1077#1076#1088#1072': '
      Layout = tlCenter
    end
    object cbKafedra: TComboBox
      Left = 70
      Top = 2
      Width = 250
      Height = 22
      Style = csOwnerDrawFixed
      Enabled = False
      ItemHeight = 16
      TabOrder = 0
      OnChange = ComboChange
      OnDrawItem = OnDrawItem
    end
  end
  object GroupSet: TADODataSet
    CursorType = ctStatic
    OnNewRecord = GroupSetNewRecord
    Parameters = <>
    Left = 420
    Top = 75
    object GroupSet_grid: TLargeintField
      DisplayLabel = 'ID'
      FieldName = 'grid'
      ReadOnly = True
    end
    object GroupSet_kid: TLargeintField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      FieldName = 'kid'
      OnGetText = GroupSetkidGetText
    end
    object GroupSet_grName: TStringField
      DisplayLabel = #1053#1072#1079#1074#1072#1085#1080#1077
      FieldName = 'grName'
      Size = 10
    end
    object GroupSet_studs: TSmallintField
      DisplayLabel = #1057#1090#1091#1076#1077#1085#1090#1099
      FieldName = 'studs'
    end
    object GroupSet_course: TWordField
      DisplayLabel = #1050#1091#1088#1089
      FieldName = 'course'
    end
    object GroupSet_ynum: TSmallintField
      DisplayLabel = #1043#1086#1076
      FieldName = 'ynum'
    end
  end
  object DataSource: TDataSource
    DataSet = GroupSet
    Left = 490
    Top = 75
  end
end
