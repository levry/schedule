object frmRecordsetDlg: TfrmRecordsetDlg
  Left = 192
  Top = 107
  Width = 425
  Height = 295
  BorderStyle = bsSizeToolWin
  Caption = 'frmRecordsetDlg'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object DBGridEh: TDBGridEh
    Left = 0
    Top = 0
    Width = 417
    Height = 268
    Align = alClient
    DataSource = DataSource
    Flat = True
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'MS Sans Serif'
    FooterFont.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DataSet: TADODataSet
    Parameters = <>
    Left = 245
    Top = 40
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 305
    Top = 40
  end
end
