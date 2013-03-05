object frmKafedrs: TfrmKafedrs
  Left = 191
  Top = 81
  ActiveControl = DBGrid
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
  Position = poDefault
  OnCreate = FormCreate
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
    Columns = <
      item
        Expanded = False
        FieldName = 'kName'
        Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 250
        Visible = True
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
    TabOrder = 1
  end
  object DataSet: TADODataSet
    Connection = dmMain.Connection
    Parameters = <>
    Left = 135
    Top = 55
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 195
    Top = 55
  end
  object ActionList: TActionList
    Left = 135
    Top = 110
  end
end
