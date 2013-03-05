object frmFaculty: TfrmFaculty
  Left = 191
  Top = 81
  AutoScroll = False
  Caption = #1060#1072#1082#1091#1083#1100#1090#1077#1090#1099
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
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 610
    Top = 30
  end
  object DataSet: TADODataSet
    Connection = dmAdmin.Connection
    Parameters = <>
    Left = 540
    Top = 30
  end
end
