object frmTeachDlg: TfrmTeachDlg
  Left = 180
  Top = 107
  BorderStyle = bsDialog
  Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
  ClientHeight = 453
  ClientWidth = 372
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    372
    453)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 30
    Top = 65
    Width = 52
    Height = 13
    Caption = #1060#1072#1084#1080#1083#1080#1103':'
  end
  object Label2: TLabel
    Left = 30
    Top = 95
    Width = 25
    Height = 13
    Caption = #1048#1084#1103':'
  end
  object Label3: TLabel
    Left = 30
    Top = 125
    Width = 55
    Height = 13
    Caption = #1054#1090#1095#1077#1090#1089#1090#1074#1086':'
  end
  object Label4: TLabel
    Left = 30
    Top = 155
    Width = 65
    Height = 13
    Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100':'
  end
  object Label5: TLabel
    Left = 30
    Top = 185
    Width = 83
    Height = 13
    Caption = #1044#1077#1085#1100' '#1088#1086#1078#1076#1077#1085#1080#1103':'
  end
  object Label6: TLabel
    Left = 30
    Top = 215
    Width = 34
    Height = 13
    Caption = #1040#1076#1088#1077#1089':'
  end
  object Label7: TLabel
    Left = 30
    Top = 315
    Width = 48
    Height = 13
    Caption = #1058#1077#1083#1077#1092#1086#1085':'
  end
  object Label8: TLabel
    Left = 30
    Top = 345
    Width = 61
    Height = 13
    Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100':'
  end
  object Label10: TLabel
    Left = 30
    Top = 375
    Width = 48
    Height = 13
    Caption = #1050#1072#1092#1077#1076#1088#1072':'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 410
    Width = 372
    Height = 43
    Align = alBottom
    Shape = bsTopLine
  end
  object lblKafedra: TLabel
    Left = 160
    Top = 370
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    BiDiMode = bdRightToLeft
    ParentBiDiMode = False
    Layout = tlCenter
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 372
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102' '#1086' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1077
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object Edit1: TEdit
    Tag = 1
    Left = 160
    Top = 60
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 1
    OnChange = EditsChange
  end
  object Edit2: TEdit
    Tag = 2
    Left = 160
    Top = 90
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 2
    OnChange = EditsChange
  end
  object Edit3: TEdit
    Tag = 3
    Left = 160
    Top = 120
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 3
    OnChange = EditsChange
  end
  object Edit4: TEdit
    Left = 160
    Top = 150
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 4
  end
  object Edit6: TEdit
    Left = 160
    Top = 310
    Width = 200
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 6
  end
  object Memo1: TMemo
    Left = 160
    Top = 210
    Width = 200
    Height = 91
    Anchors = [akTop, akRight]
    TabOrder = 5
  end
  object OkBtn: TButton
    Tag = 1
    Left = 122
    Top = 421
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 7
    OnClick = BtnsClick
  end
  object CancelBtn: TButton
    Tag = 3
    Left = 292
    Top = 421
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 8
    OnClick = BtnsClick
  end
  object AddBtn: TButton
    Tag = 2
    Left = 207
    Top = 421
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 9
    OnClick = BtnsClick
  end
  object cbPost: TComboBox
    Left = 160
    Top = 340
    Width = 200
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    TabOrder = 10
    OnDrawItem = cbDrawItem
  end
  object Edit5: TMaskEdit
    Left = 160
    Top = 180
    Width = 198
    Height = 21
    EditMask = '!00/00/0000;1;_'
    MaxLength = 10
    TabOrder = 11
    Text = '  .  .    '
  end
end
