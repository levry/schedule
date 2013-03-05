object frmDeclare: TfrmDeclare
  Left = 191
  Top = 107
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1047#1072#1103#1074#1082#1080' '#1085#1072' '#1082#1072#1092#1077#1076#1088#1091
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
        FieldName = 'grName'
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
      end>
  end
  object DeclareSet: TADODataSet
    AutoCalcFields = False
    Connection = dmMain.Connection
    CursorType = ctStatic
    OnCalcFields = DeclareSetCalcFields
    Parameters = <>
    Left = 545
    Top = 45
    object DeclareSetsbCode: TStringField
      DisplayLabel = #1050#1086#1076
      DisplayWidth = 10
      FieldName = 'sbCode'
    end
    object DeclareSetsbName: TStringField
      DisplayLabel = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
      DisplayWidth = 30
      FieldName = 'sbName'
      Size = 100
    end
    object DeclareSetgrName: TStringField
      DisplayLabel = #1043#1088#1091#1087#1087#1072
      FieldName = 'grName'
      Size = 10
    end
    object DeclareSetTotalHLP: TIntegerField
      DisplayLabel = #1042#1089#1077#1075#1086
      DisplayWidth = 5
      FieldName = 'TotalHLP'
    end
    object DeclareSetTotalAHLP: TIntegerField
      DisplayLabel = #1040#1091#1076'. '#1095
      DisplayWidth = 5
      FieldName = 'TotalAHLP'
    end
    object DeclareSetCompl: TIntegerField
      DisplayLabel = #1056#1072#1085#1077#1077
      DisplayWidth = 5
      FieldName = 'Compl'
    end
    object DeclareSetWP1: TWordField
      DisplayLabel = #1053#1077#1076#1077#1083#1080' (1'#1087'/'#1089')'
      DisplayWidth = 5
      FieldName = 'WP1'
    end
    object DeclareSetl1: TWordField
      FieldName = 'l1'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetp1: TWordField
      FieldName = 'p1'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetlb1: TWordField
      FieldName = 'lb1'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetWP2: TWordField
      DisplayLabel = #1053#1077#1076#1077#1083#1080' (2'#1087'/'#1089')'
      FieldName = 'WP2'
    end
    object DeclareSetl2: TWordField
      FieldName = 'l2'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetp2: TWordField
      FieldName = 'p2'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetlb2: TWordField
      FieldName = 'lb2'
      ReadOnly = True
      Visible = False
    end
    object DeclareSetKp: TWordField
      DisplayLabel = #1050#1091#1088#1089#1055#1088
      DisplayWidth = 5
      FieldName = 'Kp'
    end
    object DeclareSetKr: TWordField
      DisplayLabel = #1050#1091#1088#1089#1056
      DisplayWidth = 5
      FieldName = 'Kr'
    end
    object DeclareSetRg: TWordField
      DisplayLabel = #1056#1075#1056
      DisplayWidth = 5
      FieldName = 'Rg'
    end
    object DeclareSetCr: TWordField
      DisplayLabel = #1050#1086#1085#1090#1056
      DisplayWidth = 5
      FieldName = 'Cr'
    end
    object DeclareSetHr: TWordField
      DisplayLabel = #1044#1086#1084#1056
      DisplayWidth = 5
      FieldName = 'Hr'
    end
    object DeclareSetKoll: TWordField
      DisplayLabel = #1050#1083#1082#1074#1084
      DisplayWidth = 5
      FieldName = 'Koll'
    end
    object DeclareSetZ: TWordField
      DisplayLabel = #1047#1072#1095'.'
      DisplayWidth = 5
      FieldName = 'Z'
    end
    object DeclareSetE: TWordField
      DisplayLabel = #1069#1082#1079
      DisplayWidth = 5
      FieldName = 'E'
    end
    object DeclareSetHours1: TStringField
      DisplayLabel = #1063'/'#1085' (1'#1087'/'#1089')'
      DisplayWidth = 10
      FieldKind = fkCalculated
      FieldName = 'Hours1'
      Calculated = True
    end
    object DeclareSetHours2: TStringField
      DisplayLabel = #1063'/'#1085' (2'#1087'/'#1089')'
      DisplayWidth = 10
      FieldKind = fkCalculated
      FieldName = 'Hours2'
      Calculated = True
    end
    object DeclareSetLec: TSmallintField
      DisplayLabel = #1051#1077#1082'.'
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Lec'
      Calculated = True
    end
    object DeclareSetPrc: TSmallintField
      DisplayLabel = #1055#1088#1082#1090
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Prc'
      Calculated = True
    end
    object DeclareSetLab: TSmallintField
      DisplayLabel = #1051#1072#1073
      DisplayWidth = 5
      FieldKind = fkCalculated
      FieldName = 'Lab'
      Calculated = True
    end
  end
  object DataSource: TDataSource
    DataSet = DeclareSet
    Left = 610
    Top = 45
  end
end
