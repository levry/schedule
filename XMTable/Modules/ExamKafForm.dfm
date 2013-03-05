object frmExamKafedra: TfrmExamKafedra
  Left = 328
  Top = 260
  Width = 696
  Height = 480
  Caption = #1069#1082#1079#1072#1084#1077#1085#1099' '#1082#1072#1092#1077#1076#1088#1099
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
    Height = 22
    EdgeBorders = []
    Flat = True
    Images = dmExam.BtnImageList
    TabOrder = 0
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
    object lblKafedra: TLabel
      Left = 46
      Top = 0
      Width = 80
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = #1050#1072#1092#1077#1076#1088#1072': '
      Layout = tlCenter
    end
    object cbKafedra: TComboBox
      Left = 126
      Top = 0
      Width = 200
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnChange = ComboChange
      OnDrawItem = ComboDrawItem
    end
  end
  object TabControl: TTabControl
    Left = 0
    Top = 22
    Width = 688
    Height = 24
    Align = alTop
    Style = tsFlatButtons
    TabOrder = 1
    Tabs.Strings = (
      #1069#1082#1079#1072#1084#1077#1085#1099
      #1050#1086#1085#1089#1091#1083#1100#1090#1072#1094#1080#1080)
    TabIndex = 0
    OnChange = TabControlChange
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 46
    Width = 688
    Height = 407
    Align = alClient
    DataSource = DataSource
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'Initials'
        Title.Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
        Width = 117
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'grName'
        Title.Caption = #1043#1088#1091#1087#1087#1072
        Width = 103
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sbName'
        Title.Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        Width = 214
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'xmtime'
        Title.Caption = #1042#1088#1077#1084#1103
        Width = 112
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'aName'
        Title.Caption = #1040#1091#1076#1080#1090#1086#1088#1080#1103
        Width = 102
        Visible = True
      end>
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 505
    Top = 55
  end
  object DataSet: TADODataSet
    Parameters = <>
    Left = 440
    Top = 55
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Filter = 'Excel file|*.xls|Any file|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 505
    Top = 110
  end
end
