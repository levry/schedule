object frmPosts: TfrmPosts
  Left = 244
  Top = 104
  AutoScroll = False
  Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1080
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
    Top = 0
    Width = 688
    Height = 453
    Align = alClient
    DataSource = DataSource
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DataSet: TADODataSet
    Connection = dmAdmin.Connection
    CursorType = ctStatic
    Parameters = <>
    Left = 565
    Top = 20
    object DataSetpid: TAutoIncField
      DisplayLabel = 'ID'
      FieldName = 'pid'
      ReadOnly = True
    end
    object DataSetpname: TStringField
      DisplayLabel = #1044#1086#1078#1085#1086#1089#1090#1100
      FieldName = 'pname'
    end
    object DataSetpsmall: TStringField
      DisplayLabel = #1057#1086#1082#1088#1072#1097#1077#1085#1080#1077
      FieldName = 'psmall'
      Size = 10
    end
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 625
    Top = 20
  end
end
