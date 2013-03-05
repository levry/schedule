object fmEditLsns: TfmEditLsns
  Left = 0
  Top = 0
  Width = 215
  Height = 105
  AutoScroll = False
  TabOrder = 0
  object tcType: TTabControl
    Left = 0
    Top = 0
    Width = 215
    Height = 105
    Align = alClient
    MultiLine = True
    TabHeight = 12
    TabOrder = 0
    TabPosition = tpRight
    Tabs.Strings = (
      #1051#1077#1082#1094#1080#1103)
    TabIndex = 0
    TabStop = False
    DesignSize = (
      215
      105)
    object Bevel1: TBevel
      Left = 40
      Top = 30
      Width = 105
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object Bevel2: TBevel
      Left = 40
      Top = 55
      Width = 105
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object lblSubject: TLabel
      Left = 5
      Top = 5
      Width = 181
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object imgAuditory: TImage
      Left = 10
      Top = 55
      Width = 21
      Height = 21
      Center = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        000010000000010004000000000080000000C40E0000C40E0000100000000000
        0000000000000000800000800000008080008000000080008000808000008080
        8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFF70FFFFFFFFFFF777870FFFFFFFF77F8F8700
        FFFFFF78F8F887000FFFFF7F8F8F870770FFFF78FF88877770FFFF7F88888877
        70FFFF788888777870FFFF788877778870FFFFF78777888877FFFFFF7F788877
        FFFFFFFFFF7877FFFFFFFFFFFF77FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object imgTeacher: TImage
      Left = 10
      Top = 30
      Width = 21
      Height = 21
      Center = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        000010000000010004000000000080000000C40E0000C40E0000100000000000
        0000000000000000800000800000008080008000000080008000808000008080
        8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000FFFF000F
        FFFF08E80FF08E80FFFF0E8E0FF0E8E0FFFF0FE80FF0FE80FFFF0EFE0FF0EFE0
        FFFFF000F00F000FFFFFF0FFFFFFFFF0FFF0FF0FFF0FFFFF0FF0FFF0FF0FFFFF
        F0F0FFFF0F0FFFFFFF0FFFFFF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF}
      Transparent = True
    end
    object lblTeacher: TLabel
      Tag = 1
      Left = 40
      Top = 30
      Width = 105
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Layout = tlCenter
      OnDblClick = DoChange
    end
    object btnTeacherList: TSpeedButton
      Tag = 1
      Left = 150
      Top = 31
      Width = 18
      Height = 18
      Anchors = [akTop, akRight]
      Flat = True
      Glyph.Data = {
        46000000424D46000000000000003E000000280000000B000000020000000100
        01000000000008000000C40E0000C40E0000020000000000000000000000FFFF
        FF009980000099800000}
      Layout = blGlyphRight
      Transparent = False
      OnClick = DoChange
    end
    object lblAuditory: TLabel
      Tag = 2
      Left = 40
      Top = 55
      Width = 105
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Layout = tlCenter
      OnDblClick = DoChange
    end
    object btnAuditoryList: TSpeedButton
      Tag = 2
      Left = 150
      Top = 56
      Width = 18
      Height = 18
      Hint = #1040#1091#1076#1080#1090#1086#1088#1080#1080' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      Anchors = [akTop, akRight]
      Flat = True
      Glyph.Data = {
        46000000424D46000000000000003E000000280000000B000000020000000100
        01000000000008000000C40E0000C40E0000020000000000000000000000FFFF
        FF009980000099800000}
      Layout = blGlyphRight
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      OnClick = DoChange
    end
    object btnAuditoryKafList: TSpeedButton
      Tag = 4
      Left = 170
      Top = 56
      Width = 18
      Height = 18
      Hint = #1040#1091#1076#1080#1090#1086#1088#1080#1080' '#1082#1072#1092#1077#1076#1088#1099
      Anchors = [akTop, akRight]
      Flat = True
      Glyph.Data = {
        C6000000424DC6000000000000007600000028000000090000000A0000000100
        04000000000050000000C40E0000C40E00001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDD7770DD000
        0000D778F770D00000007F8F87770000000078F8F777000000007F8FF7770000
        00007FF88F7700000000788888F700000000D788888700000000DD78877DD000
        0000DDD77DDDD0000000}
      Layout = blGlyphRight
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      OnClick = DoChange
    end
    object chkSub: TCheckBox
      Tag = 3
      Left = 35
      Top = 82
      Width = 151
      Height = 17
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      Caption = #1087#1086#1076#1075#1088#1091#1087#1087#1072
      TabOrder = 0
      OnClick = DoChange
    end
  end
end
