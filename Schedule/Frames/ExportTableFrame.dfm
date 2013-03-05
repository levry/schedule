object fmExportTable: TfmExportTable
  Left = 0
  Top = 0
  Width = 340
  Height = 415
  AutoScroll = False
  TabOrder = 0
  DesignSize = (
    340
    415)
  object boxElement: TGroupBox
    Left = 5
    Top = 115
    Width = 330
    Height = 126
    Anchors = [akLeft, akTop, akRight]
    Caption = #1069#1083#1077#1084#1077#1085#1090#1099
    TabOrder = 0
    object lbElements: TListBox
      Left = 15
      Top = 45
      Width = 121
      Height = 66
      ItemHeight = 13
      Items.Strings = (
        #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        #1040#1091#1076#1080#1090#1086#1088#1080#1103
        #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100)
      TabOrder = 0
      OnClick = lbElementsClick
    end
    object ToolBar: TToolBar
      Left = 2
      Top = 15
      Width = 326
      Height = 22
      AutoSize = True
      EdgeBorders = []
      Flat = True
      Images = ImageList
      Indent = 10
      TabOrder = 1
      object btnDown: TToolButton
        Tag = 5
        Left = 10
        Top = 0
        Caption = 'btnDown'
        Enabled = False
        ImageIndex = 0
        OnClick = OnElementBtnsClick
      end
      object btnUp: TToolButton
        Tag = 4
        Left = 33
        Top = 0
        Caption = 'btnUp'
        Enabled = False
        ImageIndex = 1
        OnClick = OnElementBtnsClick
      end
      object ToolButton3: TToolButton
        Left = 56
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object cbSize: TComboBox
        Left = 64
        Top = 0
        Width = 56
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbSizeChange
        Items.Strings = (
          '8'
          '9'
          '10'
          '11'
          '12'
          '14'
          '16'
          '18'
          '20'
          '22'
          '24'
          '26'
          '28'
          '36'
          '48'
          '72')
      end
      object ToolButton4: TToolButton
        Left = 120
        Top = 0
        Width = 8
        Caption = 'ToolButton4'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object btnBold: TToolButton
        Tag = 1
        Left = 128
        Top = 0
        Caption = 'btnBold'
        ImageIndex = 2
        Style = tbsCheck
        OnClick = OnElementBtnsClick
      end
      object btnItalic: TToolButton
        Tag = 2
        Left = 151
        Top = 0
        Caption = 'btnItalic'
        ImageIndex = 3
        Style = tbsCheck
        OnClick = OnElementBtnsClick
      end
      object btnUnderline: TToolButton
        Tag = 3
        Left = 174
        Top = 0
        Caption = 'btnUnderline'
        ImageIndex = 4
        Style = tbsCheck
        OnClick = OnElementBtnsClick
      end
    end
  end
  object boxFills: TGroupBox
    Left = 5
    Top = 5
    Width = 330
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = #1047#1072#1083#1080#1074#1082#1072
    TabOrder = 1
    object lblLection: TLabel
      Left = 15
      Top = 20
      Width = 95
      Height = 21
      AutoSize = False
      Caption = #1051#1077#1082#1094#1080#1080
      Layout = tlCenter
    end
    object lblPractics: TLabel
      Left = 15
      Top = 45
      Width = 95
      Height = 21
      AutoSize = False
      Caption = #1055#1088#1072#1082#1090#1080#1082#1080
      Layout = tlCenter
    end
    object lblLabo: TLabel
      Left = 15
      Top = 70
      Width = 95
      Height = 21
      AutoSize = False
      Caption = #1051#1072#1073#1086#1088#1072#1090#1086#1088#1085#1099#1077
      Layout = tlCenter
    end
    object cbLesson: TComboBox
      Tag = 1
      Left = 115
      Top = 20
      Width = 80
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      OnChange = cbPatternChange
      OnDrawItem = ComboDrawItem
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
    object cbPractic: TComboBox
      Tag = 2
      Left = 115
      Top = 45
      Width = 80
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 1
      OnChange = cbPatternChange
      OnDrawItem = ComboDrawItem
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
    object cbLabo: TComboBox
      Tag = 3
      Left = 115
      Top = 70
      Width = 80
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 2
      OnChange = cbPatternChange
      OnDrawItem = ComboDrawItem
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
    end
  end
  object boxOther: TGroupBox
    Left = 5
    Top = 245
    Width = 330
    Height = 130
    Anchors = [akLeft, akTop, akRight]
    Caption = #1054#1092#1086#1088#1084#1083#1077#1085#1080#1077
    TabOrder = 2
    object lblParityStyle: TLabel
      Left = 15
      Top = 45
      Width = 110
      Height = 21
      AutoSize = False
      Caption = #1057#1090#1080#1083#1100' '#1095#1077#1090#1085#1086#1089#1090#1080':'
      Layout = tlCenter
    end
    object lblSmall: TLabel
      Left = 15
      Top = 70
      Width = 110
      Height = 21
      AutoSize = False
      Caption = #1057#1086#1082#1088#1072#1097#1072#1090#1100' '#1087#1088#1080' (%):'
      Layout = tlCenter
    end
    object lblDoublePair: TLabel
      Left = 15
      Top = 95
      Width = 110
      Height = 21
      AutoSize = False
      Caption = #1044#1074#1086#1081#1085#1099#1077' '#1087#1072#1088#1099' ('#1082'/'#1085'):'
      Layout = tlCenter
    end
    object chkMerge: TCheckBox
      Left = 15
      Top = 25
      Width = 286
      Height = 17
      Caption = #1054#1073#1098#1077#1076#1080#1085#1077#1085#1080#1077' '#1103#1095#1077#1077#1082' '#1087#1086#1090#1086#1082#1086#1074
      TabOrder = 0
      OnClick = chkMergeClick
    end
    object cbParityStyle: TComboBox
      Tag = 4
      Left = 130
      Top = 45
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbOtherChange
      Items.Strings = (
        #1092#1080#1075#1091#1088#1085#1072#1103' '#1089#1082#1086#1073#1082#1072
        #1089#1090#1080#1083#1100' '#1096#1072#1073#1083#1086#1085#1072)
    end
    object cbSmall: TComboBox
      Tag = 5
      Left = 130
      Top = 70
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbOtherChange
      Items.Strings = (
        '10'
        '20'
        '30'
        '50'
        '80'
        '100')
    end
    object cbDoublePair: TComboBox
      Tag = 6
      Left = 130
      Top = 95
      Width = 121
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbOtherChange
      Items.Strings = (
        #1086#1090#1076#1077#1083#1100#1085#1086
        #1086#1073#1098#1077#1076#1080#1085#1077#1085#1080#1077' ('#1089#1076#1074#1080#1075')'
        #1086#1073#1098#1077#1076#1080#1085#1077#1085#1080#1077' ('#1087#1086#1083#1085#1086#1077')')
    end
  end
  object btnDefault: TButton
    Left = 260
    Top = 385
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1057#1073#1088#1086#1089
    TabOrder = 3
    OnClick = btnDefaultClick
  end
  object ImageList: TImageList
    Left = 235
    Top = 45
  end
end
