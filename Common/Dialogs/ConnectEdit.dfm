object frmConEdit: TfrmConEdit
  Left = 191
  Top = 81
  BorderStyle = bsDialog
  Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 253
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    377
    253)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 10
    Top = 50
    Width = 360
    Height = 6
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 75
    Top = 20
    Width = 196
    Height = 21
    AutoSize = False
    Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
    Layout = tlCenter
  end
  object rbUseFile: TRadioButton
    Left = 15
    Top = 80
    Width = 261
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1092#1072#1081#1083' '#1089#1074#1103#1079#1080
    TabOrder = 0
    OnClick = OnUseClick
  end
  object rbUseString: TRadioButton
    Left = 15
    Top = 135
    Width = 261
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1089#1090#1088#1086#1082#1091' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103
    TabOrder = 3
    OnClick = OnUseClick
  end
  object edFile: TEdit
    Left = 25
    Top = 105
    Width = 256
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object edString: TEdit
    Left = 25
    Top = 160
    Width = 256
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object btnOpen: TButton
    Tag = 1
    Left = 290
    Top = 103
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088
    TabOrder = 2
    OnClick = OnBtnsClick
  end
  object btnBuild: TButton
    Tag = 2
    Left = 290
    Top = 158
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 5
    OnClick = OnBtnsClick
  end
  object btnOk: TButton
    Left = 205
    Top = 220
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 290
    Top = 220
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
end
