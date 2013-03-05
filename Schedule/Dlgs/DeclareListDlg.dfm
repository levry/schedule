object frmDeclareListDlg: TfrmDeclareListDlg
  Left = 191
  Top = 81
  Width = 398
  Height = 427
  BorderStyle = bsSizeToolWin
  Caption = #1047#1072#1103#1074#1082#1080
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    390
    400)
  PixelsPerInch = 96
  TextHeight = 13
  object lblGroupBy: TLabel
    Left = 125
    Top = 5
    Width = 111
    Height = 21
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = #1043#1088#1091#1087#1087#1080#1088#1086#1074#1072#1090#1100':'
    Layout = tlCenter
  end
  object vstDeclares: TVirtualStringTree
    Left = 5
    Top = 35
    Width = 381
    Height = 326
    Anchors = [akLeft, akTop, akRight, akBottom]
    CheckImageKind = ckLightTick
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoVisible]
    Header.Style = hsFlatButtons
    ParentBackground = False
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toThemeAware, toUseBlendedImages]
    OnChecked = vstDeclaresChecked
    OnGetText = vstDeclaresGetText
    Columns = <
      item
        Position = 0
        Width = 297
        WideText = #1047#1072#1103#1074#1082#1072
      end
      item
        MinWidth = 80
        Position = 1
        Width = 80
        WideText = #1053#1072#1075#1088#1091#1079#1082#1072
      end>
  end
  object btnOk: TButton
    Left = 230
    Top = 370
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 310
    Top = 370
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object cbGroupBy: TComboBox
    Left = 240
    Top = 5
    Width = 145
    Height = 21
    Style = csDropDownList
    Anchors = [akTop, akRight]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = #1087#1086' '#1075#1088#1091#1087#1087#1077
    OnChange = cbGroupByChange
    Items.Strings = (
      #1087#1086' '#1075#1088#1091#1087#1087#1077
      #1087#1086' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1077
      #1087#1086' '#1082#1091#1088#1089#1091)
  end
end
