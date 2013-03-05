object frmSubjectListDlg: TfrmSubjectListDlg
  Left = 191
  Top = 105
  Width = 408
  Height = 357
  BorderStyle = bsSizeToolWin
  Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1099
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 220
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    400
    330)
  PixelsPerInch = 96
  TextHeight = 13
  object HTMLabel: THTMLabel
    Left = 5
    Top = 0
    Width = 390
    Height = 31
    Anchors = [akLeft, akTop, akRight]
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
  object btnOk: TButton
    Left = 240
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 320
    Top = 300
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 5
    Top = 35
    Width = 390
    Height = 255
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 16
    TabOrder = 2
    OnDblClick = ListBoxDbClick
    OnDrawItem = ListBoxDrawItem
  end
end
