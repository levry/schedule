object frmMain: TfrmMain
  Left = 328
  Top = 170
  AutoScroll = False
  Caption = #1056#1072#1073#1086#1095#1080#1081' '#1087#1083#1072#1085
  ClientHeight = 434
  ClientWidth = 688
  Color = clAppWorkSpace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 185
    Top = 22
    Height = 393
    Color = clBtnFace
    ParentColor = False
    Visible = False
  end
  object BrowserPanel: TPanel
    Left = 0
    Top = 22
    Width = 185
    Height = 393
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinWidth = 50
    TabOrder = 0
    Visible = False
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 22
    AutoSize = True
    Color = clBtnFace
    EdgeBorders = []
    Flat = True
    Images = MainImageList
    ParentColor = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnSem: TToolButton
      Left = 0
      Top = 0
      Action = actViewSem
      DropdownMenu = SemMenu
      Style = tbsDropDown
    end
    object btnPSem: TToolButton
      Left = 36
      Top = 0
      Action = actViewPSem
      DropdownMenu = PSemMenu
      Style = tbsDropDown
    end
    object ToolButton4: TToolButton
      Left = 72
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object btnViewBrowser: TToolButton
      Left = 80
      Top = 0
      Action = actViewBrowser
    end
    object btnViewGroups: TToolButton
      Left = 103
      Top = 0
      Action = actViewGroups
    end
  end
  object ModulePanel: TPanel
    Left = 188
    Top = 22
    Width = 500
    Height = 393
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object CaptionLabel: TLabel
      Left = 0
      Top = 0
      Width = 500
      Height = 18
      Align = alTop
      AutoSize = False
      Color = clInactiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clCaptionText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object TabControl: TTabControl
      Left = 0
      Top = 372
      Width = 500
      Height = 21
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Style = tsFlatButtons
      TabOrder = 0
      OnChange = TabControlChange
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 415
    Width = 688
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 100
      end
      item
        Width = 150
      end>
    OnResize = StatusBarResize
  end
  object ActionList: TActionList
    Images = MainImageList
    Left = 515
    Top = 15
    object actViewPSem: TAction
      Tag = -3
      Category = 'View'
      Caption = #1055#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      Hint = #1055#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actViewSem: TAction
      Tag = -2
      Category = 'View'
      Caption = #1057#1077#1084#1077#1089#1090#1088
      Hint = #1057#1077#1084#1077#1089#1090#1088
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actViewUpdate: TAction
      Tag = -1
      Category = 'View'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      Visible = False
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actProjectExit: TFileExit
      Category = 'Project'
      Caption = #1042#1099#1093#1086#1076
      Hint = 'Exit|Quits the application'
      ImageIndex = 43
    end
    object actViewBrowser: TAction
      Tag = 1
      Category = 'View'
      Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072
      Hint = #1057#1090#1088#1091#1082#1090#1091#1088#1072
      ImageIndex = 13
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actViewGroups: TAction
      Tag = 2
      Category = 'View'
      Caption = #1043#1088#1091#1087#1087#1099
      Hint = #1043#1088#1091#1087#1087#1099
      ImageIndex = 12
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actProjectConnect: TAction
      Tag = 1
      Category = 'Project'
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077
      Hint = #1057#1086#1077#1076#1080#1085#1080#1090#1100#1089#1103' '#1089' '#1041#1044
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actProjectDisconnect: TAction
      Tag = 2
      Category = 'Project'
      Caption = #1056#1072#1079#1100#1077#1076#1080#1085#1077#1085#1080#1077
      Hint = #1056#1072#1079#1100#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actProjectEditLink: TAction
      Tag = 3
      Category = 'Project'
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1041#1044' ...'
      Hint = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1074#1103#1079#1080' '#1089' '#1041#1044
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actProjectFirstSem: TAction
      Tag = 4
      Category = 'Project'
      Caption = #1054#1089#1077#1085#1085#1080#1081
      Hint = #1054#1089#1077#1085#1085#1080#1081
      ImageIndex = 3
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectSecondSem: TAction
      Tag = 5
      Category = 'Project'
      Caption = #1042#1077#1089#1077#1085#1085#1080#1081
      Hint = #1042#1077#1089#1077#1085#1085#1080#1081
      ImageIndex = 4
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectFirstPSem: TAction
      Tag = 6
      Category = 'Project'
      Caption = '1 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      Hint = '1 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      ImageIndex = 5
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectSecondPSem: TAction
      Tag = 7
      Category = 'Project'
      Caption = '2 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      Hint = '2 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      ImageIndex = 6
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectYear: TAction
      Tag = 8
      Category = 'Project'
      Caption = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      Hint = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actHelpTopics: TAction
      Tag = 1
      Category = 'Help'
      Caption = #1057#1087#1088#1072#1074#1082#1072': '#1055#1088#1086#1075#1088#1072#1084#1084#1072
      Hint = #1057#1087#1088#1072#1074#1082#1072
      OnExecute = HelpActionsExecute
      OnUpdate = HelpActionsUpdate
    end
    object actHelpModule: TAction
      Tag = 2
      Category = 'Help'
      Caption = #1057#1087#1088#1072#1074#1082#1072': '#1084#1086#1076#1091#1083#1100
      Hint = #1057#1087#1088#1072#1074#1082#1072' '#1084#1086#1076#1091#1083#1103
      OnExecute = HelpActionsExecute
      OnUpdate = HelpActionsUpdate
    end
  end
  object MainMenu: TMainMenu
    Images = MainImageList
    Left = 515
    Top = 65
    object mnuProject: TMenuItem
      Caption = #1055#1088#1086#1077#1082#1090
      object mnuProjectYear: TMenuItem
        Action = actProjectYear
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mnuProjectConnect: TMenuItem
        Action = actProjectConnect
      end
      object mnuProjectDisconnect: TMenuItem
        Action = actProjectDisconnect
      end
      object mnuProjectEditLink: TMenuItem
        Action = actProjectEditLink
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuProjectExit: TMenuItem
        Action = actProjectExit
      end
    end
    object mnuView: TMenuItem
      Caption = #1042#1080#1076
      object mnuViewBrowser: TMenuItem
        Action = actViewBrowser
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuViewGroup: TMenuItem
        Action = actViewGroups
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuViewUpdate: TMenuItem
        Action = actViewUpdate
      end
    end
    object mnuHelp: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object mnuHelpTopics: TMenuItem
        Action = actHelpTopics
      end
      object mnuHelpModule: TMenuItem
        Action = actHelpModule
      end
    end
  end
  object SemMenu: TPopupMenu
    Images = MainImageList
    Left = 451
    Top = 67
    object mnuFirstSem: TMenuItem
      Action = actProjectFirstSem
    end
    object mnuSecondSem: TMenuItem
      Action = actProjectSecondSem
    end
  end
  object PSemMenu: TPopupMenu
    Images = MainImageList
    Left = 451
    Top = 117
    object mnuFirstPSem: TMenuItem
      Action = actProjectFirstPSem
    end
    object mnuSecondPSem: TMenuItem
      Action = actProjectSecondPSem
    end
  end
  object MainImageList: TImageList
    Left = 580
    Top = 15
  end
end
