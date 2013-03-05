object frmExamEdit: TfrmExamEdit
  Left = 243
  Top = 129
  BorderStyle = bsDialog
  ClientHeight = 274
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    300
    274)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 140
    Top = 244
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 220
    Top = 244
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object TabControl: TTabControl
    Left = 5
    Top = 5
    Width = 290
    Height = 230
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Tabs.Strings = (
      #1069#1082#1079#1072#1084#1077#1085)
    TabIndex = 0
    DesignSize = (
      290
      230)
    object lblTime: TLabel
      Left = 10
      Top = 110
      Width = 90
      Height = 21
      AutoSize = False
      Caption = #1042#1088#1077#1084#1103':'
    end
    object lblTeacher: TLabel
      Left = 110
      Top = 75
      Width = 170
      Height = 30
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
    end
    object lblSubject: TLabel
      Left = 110
      Top = 40
      Width = 170
      Height = 30
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      WordWrap = True
    end
    object lblAuditory: TLabel
      Left = 110
      Top = 145
      Width = 111
      Height = 21
      AutoSize = False
    end
    object Label3: TLabel
      Left = 10
      Top = 40
      Width = 90
      Height = 21
      AutoSize = False
      Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072':'
    end
    object Label2: TLabel
      Left = 10
      Top = 145
      Width = 90
      Height = 21
      AutoSize = False
      Caption = #1040#1091#1076#1080#1090#1086#1088#1080#1103':'
    end
    object Label1: TLabel
      Left = 10
      Top = 75
      Width = 90
      Height = 21
      AutoSize = False
      Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100':'
    end
    object btnFacAuditory: TSpeedButton
      Tag = 3
      Left = 225
      Top = 145
      Width = 23
      Height = 22
      Hint = #1042#1089#1077' '#1072#1091#1076#1080#1090#1086#1088#1080#1080
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00D00000000000
        0000D0BFBFBFBFBFBFB0D000000000000000D0BBB00BBB00BBB0DD3B7DD3B7DD
        3B7DDD3F7DD3F7D73F7DDD3B7DD3B7773B7DDD3F7D73F7773F7DDD3377733777
        337DD0FBB77FBB77FBB0D000000000000000D0FFBBBBBBBBBBB0DD00FF33333B
        B00DDDDD00FF3BB00DDDDDDDDD00F00DDDDDDDDDDDDD0DDDDDDD}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAuditoryClick
    end
    object btnKafAuditory: TSpeedButton
      Tag = 4
      Left = 250
      Top = 145
      Width = 23
      Height = 22
      Hint = #1040#1091#1076#1080#1090#1086#1088#1080#1080' '#1082#1072#1092#1077#1076#1088#1099
      Flat = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDD000DDDD00
        0DDDD00EE60D009910DD7EEEE6609999110D7EEEE666099911107EEEE6660499
        11107EEFF66604FF11107FF888333088F110788833BB33088F10D787BBBB3330
        8800DD77BBBB333000DDDDD7BBFF3330DDDDDDD7FF88F330DDDDDDD788888F30
        DDDDDDDD78888870DDDDDDDDD78877DDDDDDDDDDDD77DDDDDDDD}
      Layout = blGlyphRight
      ParentShowHint = False
      ShowHint = True
      OnClick = btnAuditoryClick
    end
    object chkSubgrp: TCheckBox
      Tag = 2
      Left = 110
      Top = 170
      Width = 116
      Height = 21
      Caption = #1087#1086#1076#1075#1088#1091#1087#1087#1072
      TabOrder = 1
      OnClick = OnExamChange
    end
    object TimePicker: TDateTimePicker
      Tag = 1
      Left = 110
      Top = 110
      Width = 126
      Height = 21
      Date = 38841.375000000000000000
      Format = 'HH:mm'
      Time = 38841.375000000000000000
      Kind = dtkTime
      TabOrder = 0
      OnChange = OnExamChange
    end
  end
end
