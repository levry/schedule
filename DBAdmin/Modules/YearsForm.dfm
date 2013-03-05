object frmYears: TfrmYears
  Left = 191
  Top = 81
  AutoScroll = False
  Caption = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
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
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 29
    AutoSize = True
    EdgeBorders = []
    Flat = True
    TabOrder = 0
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 29
    Width = 688
    Height = 424
    Align = alClient
    DataSource = YearSource
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'ynum'
        Visible = True
      end>
  end
  object YearSet: TADODataSet
    Connection = dmAdmin.Connection
    CursorType = ctStatic
    AfterScroll = YearSetAfterScroll
    Parameters = <>
    Left = 560
    Top = 55
    object YearSetynum: TSmallintField
      DisplayLabel = #1043#1086#1076
      FieldName = 'ynum'
    end
  end
  object YearSource: TDataSource
    DataSet = YearSet
    Left = 625
    Top = 55
  end
end
