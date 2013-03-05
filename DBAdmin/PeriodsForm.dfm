object frmPeriods: TfrmPeriods
  Left = 190
  Top = 78
  Width = 568
  Height = 170
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = #1055#1083#1072#1085
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 560
    Height = 29
    AutoSize = True
    EdgeBorders = []
    Flat = True
    TabOrder = 0
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 29
    Width = 560
    Height = 93
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
        FieldName = 'prid'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'ynum'
        ReadOnly = True
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'sem'
        ReadOnly = True
        Width = 80
        Visible = True
      end
      item
        ButtonStyle = cbsEllipsis
        Expanded = False
        FieldName = 'ptype'
        ReadOnly = True
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'p_start'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'p_end'
        Width = 100
        Visible = True
      end>
  end
  object TabSet: TTabSet
    Left = 0
    Top = 122
    Width = 560
    Height = 21
    Align = alBottom
    AutoScroll = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    SoftTop = True
    Tabs.Strings = (
      #1054#1089#1077#1085#1085#1080#1081
      #1042#1077#1089#1077#1085#1085#1080#1081)
    TabIndex = 0
    OnChange = TabSetChange
  end
  object DataSet: TADODataSet
    Connection = dmAdmin.Connection
    CursorType = ctStatic
    OnNewRecord = DataSetNewRecord
    Parameters = <>
    Left = 270
    Top = 70
    object DataSetprid: TAutoIncField
      FieldName = 'prid'
      ReadOnly = True
    end
    object DataSetynum: TSmallintField
      DisplayLabel = #1043#1086#1076
      FieldName = 'ynum'
    end
    object DataSetsem: TWordField
      DisplayLabel = #1057#1077#1084#1077#1089#1090#1088
      FieldName = 'sem'
      OnGetText = DataSetGetText
    end
    object DataSetptype: TWordField
      DisplayLabel = #1055#1077#1088#1080#1086#1076
      FieldName = 'ptype'
      OnGetText = DataSetGetText
    end
    object DataSetp_start: TDateTimeField
      DisplayLabel = #1053#1072#1095#1072#1083#1086
      FieldName = 'p_start'
      EditMask = '!99/99/0000;1;_'
    end
    object DataSetp_end: TDateTimeField
      DisplayLabel = #1050#1086#1085#1077#1094
      FieldName = 'p_end'
      EditMask = '!99/99/0000;1;_'
    end
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 330
    Top = 70
  end
end
