object frmExamList: TfrmExamList
  Left = 243
  Top = 133
  AutoScroll = False
  Caption = #1069#1082#1079#1072#1084#1077#1085#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
  ClientHeight = 453
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid: TDBGrid
    Left = 0
    Top = 22
    Width = 688
    Height = 431
    Align = alClient
    DataSource = DataSource
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'xmtime'
        Title.Caption = #1042#1088#1077#1084#1103
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'grName'
        Title.Caption = #1043#1088#1091#1087#1087#1072
        Width = 90
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Initials'
        Title.Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sbName'
        Title.Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        Width = 250
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'aName'
        Title.Caption = #1040#1091#1076#1080#1090#1086#1088#1080#1103
        Width = 70
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
    Images = dmExam.BtnImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnExport: TToolButton
      Tag = 1
      Left = 0
      Top = 0
      Hint = #1069#1082#1089#1087#1086#1088#1090
      Caption = #1069#1082#1089#1087#1086#1088#1090
      ImageIndex = 1
      OnClick = ButtonsClick
    end
    object btnUpdate: TToolButton
      Tag = 2
      Left = 23
      Top = 0
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 0
      OnClick = ButtonsClick
    end
  end
  object ExamDataSet: TADODataSet
    Parameters = <>
    Left = 450
    Top = 25
  end
  object DataSource: TDataSource
    DataSet = ExamDataSet
    Left = 520
    Top = 25
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel file|*.xls|Any file|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 520
    Top = 75
  end
end
