object frmWorkView: TfrmWorkView
  Left = 191
  Top = 107
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1056#1072#1073#1086#1095#1080#1081' '#1087#1083#1072#1085
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
    Top = 30
    Width = 688
    Height = 423
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
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
        FieldName = 'sbCode'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sbName'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TotalHLP'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TotalAHLP'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Compl'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'WP1'
        Visible = True
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'Hours1'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'WP2'
        Visible = True
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'Hours2'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Lec'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Prc'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Lab'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Kp'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Kr'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Rg'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Cr'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Hr'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Koll'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Z'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'E'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'kName'
        Visible = True
      end>
  end
  object WorkplanSet: TADODataSet
    AutoCalcFields = False
    Connection = dmMain.Connection
    CursorType = ctStatic
    OnCalcFields = WorkplanSetCalcFields
    Parameters = <>
    Left = 490
    Top = 100
    object WorkplanSetsbCode: TStringField
      DisplayLabel = #1050#1086#1076
      DisplayWidth = 10
      FieldName = 'sbCode'
    end
    object WorkplanSetsbName: TStringField
      DisplayLabel = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
      DisplayWidth = 50
      FieldName = 'sbName'
      Size = 100
    end
    object WorkplanSetTotalHLP: TIntegerField
      DisplayLabel = #1042#1089#1077#1075#1086
      DisplayWidth = 5
      FieldName = 'TotalHLP'
    end
    object WorkplanSetTotalAHLP: TIntegerField
      DisplayLabel = #1040#1091#1076#1080#1090'. '#1095
      DisplayWidth = 5
      FieldName = 'TotalAHLP'
    end
    object WorkplanSetCompl: TIntegerField
      DisplayLabel = #1056#1072#1085#1077#1077
      DisplayWidth = 5
      FieldName = 'Compl'
    end
    object WorkplanSetWP1: TWordField
      DisplayLabel = #1053#1077#1076#1077#1083#1080' (1'#1087'/'#1089')'
      DisplayWidth = 5
      FieldName = 'WP1'
    end
    object WorkplanSetl1: TWordField
      DisplayWidth = 5
      FieldName = 'l1'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetp1: TWordField
      DisplayWidth = 5
      FieldName = 'p1'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetlb1: TWordField
      DisplayWidth = 5
      FieldName = 'lb1'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetWP2: TWordField
      DisplayLabel = #1053#1077#1076#1077#1083#1080' (2 '#1087'/'#1089')'
      DisplayWidth = 5
      FieldName = 'WP2'
    end
    object WorkplanSetl2: TWordField
      DisplayWidth = 5
      FieldName = 'l2'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetp2: TWordField
      DisplayWidth = 5
      FieldName = 'p2'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetlb2: TWordField
      DisplayWidth = 5
      FieldName = 'lb2'
      ReadOnly = True
      Visible = False
    end
    object WorkplanSetKp: TWordField
      DisplayLabel = #1050#1091#1088#1089#1055#1088
      DisplayWidth = 5
      FieldName = 'Kp'
    end
    object WorkplanSetKr: TWordField
      DisplayLabel = #1050#1091#1088#1089#1056#1073
      DisplayWidth = 5
      FieldName = 'Kr'
    end
    object WorkplanSetRg: TWordField
      DisplayLabel = #1056#1075#1088
      DisplayWidth = 5
      FieldName = 'Rg'
    end
    object WorkplanSetCr: TWordField
      DisplayLabel = #1050#1086#1085#1090#1056
      DisplayWidth = 5
      FieldName = 'Cr'
    end
    object WorkplanSetHr: TWordField
      DisplayLabel = #1044#1086#1084#1056
      DisplayWidth = 5
      FieldName = 'Hr'
    end
    object WorkplanSetKoll: TWordField
      DisplayLabel = #1050#1083#1074#1084
      DisplayWidth = 5
      FieldName = 'Koll'
    end
    object WorkplanSetZ: TWordField
      DisplayLabel = #1047#1072#1095#1077#1090
      DisplayWidth = 5
      FieldName = 'Z'
    end
    object WorkplanSetE: TWordField
      DisplayLabel = #1069#1082#1079#1072#1084#1077#1085
      DisplayWidth = 5
      FieldName = 'E'
    end
    object WorkplanSetkName: TStringField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      DisplayWidth = 30
      FieldName = 'kName'
      Size = 50
    end
    object WorkplanSetHours1: TStringField
      DisplayLabel = #1063'/'#1085' (1 '#1087'/'#1089')'
      DisplayWidth = 10
      FieldKind = fkCalculated
      FieldName = 'Hours1'
      Calculated = True
    end
    object WorkplanSetHours2: TStringField
      DisplayLabel = #1063'/'#1085' (2 '#1087'/'#1089')'
      DisplayWidth = 10
      FieldKind = fkCalculated
      FieldName = 'Hours2'
      Calculated = True
    end
    object WorkplanSetLec: TSmallintField
      DisplayLabel = #1051#1077#1082'.'
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Lec'
      Calculated = True
    end
    object WorkplanSetPrc: TSmallintField
      DisplayLabel = #1055#1088#1082#1090'.'
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Prc'
      Calculated = True
    end
    object WorkplanSetLab: TSmallintField
      DisplayLabel = #1051#1072#1073'.'
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Lab'
      Calculated = True
    end
  end
  object DataSource: TDataSource
    DataSet = WorkplanSet
    Left = 560
    Top = 100
  end
end
