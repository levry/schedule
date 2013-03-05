object frmSubjects: TfrmSubjects
  Left = 190
  Top = 104
  AutoScroll = False
  Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1099
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
  object HTMLabel: THTMLabel
    Left = 0
    Top = 22
    Width = 688
    Height = 22
    Align = alTop
    ColorTo = clNone
    AnchorHint = False
    AutoSizing = False
    AutoSizeType = asVertical
    Ellipsis = False
    GradientType = gtFullHorizontal
    HintShowFull = False
    Hover = False
    HoverColor = clNone
    HoverFontColor = clNone
    HTMLHint = False
    LineWidth = 0
    ShadowColor = clGray
    ShadowOffset = 2
    URLColor = clBlue
    VAlignment = tvaCenter
    OnAnchorClick = HTMLabelAnchorClick
    Version = '1.7.1.1'
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 44
    Width = 688
    Height = 409
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
        FieldName = 'sbName'
        Title.Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 300
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sbSmall'
        Title.Caption = #1057#1086#1082#1088#1072#1097#1077#1085#1080#1077' (20)'
        Width = 134
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
    Images = dmAdmin.BtnImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnReplace: TToolButton
      Left = 0
      Top = 0
      Action = actReplace
    end
    object btnViewGroup: TToolButton
      Left = 23
      Top = 0
      Action = actViewGroup
    end
  end
  object DataSet: TADODataSet
    Parameters = <>
    Left = 515
    Top = 65
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 580
    Top = 65
  end
  object ActionList: TActionList
    Images = dmAdmin.BtnImageList
    Left = 515
    Top = 120
    object actReplace: TAction
      Tag = 1
      Caption = #1047#1072#1084#1077#1085#1080#1090#1100
      Hint = #1047#1072#1084#1077#1085#1080#1090#1100
      ImageIndex = 0
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actViewGroup: TAction
      Tag = 2
      Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1075#1088#1091#1087#1087
      Hint = #1055#1088#1086#1089#1084#1086#1090#1088' '#1075#1088#1091#1087#1087
      ImageIndex = 1
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
end
