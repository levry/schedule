object frmMain: TfrmMain
  Left = 328
  Top = 260
  AutoScroll = False
  Caption = #1069#1082#1079#1072#1084#1077#1085#1099
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
    object ToolButton4: TToolButton
      Left = 36
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object btnViewBrowser: TToolButton
      Left = 44
      Top = 0
      Action = actViewBrowser
    end
    object btnViewExams: TToolButton
      Left = 67
      Top = 0
      Action = actViewExams
    end
    object btnViewExamList: TToolButton
      Left = 90
      Top = 0
      Action = actViewExamList
    end
    object btnViewExamKaf: TToolButton
      Left = 113
      Top = 0
      Action = actViewExamKaf
    end
    object btnViewLoadAud: TToolButton
      Left = 136
      Top = 0
      Action = actViewLoadAud
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
        Width = 200
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
      ImageIndex = 5
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actViewExams: TAction
      Tag = 2
      Category = 'View'
      Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1101#1082#1079#1072#1084#1077#1085#1086#1074
      Hint = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077' '#1101#1082#1079#1072#1084#1077#1085#1086#1074
      ImageIndex = 6
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actProjectConnect: TAction
      Tag = 1
      Category = 'Project'
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077
      Hint = #1057#1086#1077#1076#1080#1085#1080#1090#1100#1089#1103' '#1089' '#1041#1044
      ImageIndex = 0
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actProjectDisconnect: TAction
      Tag = 2
      Category = 'Project'
      Caption = #1056#1072#1079#1100#1077#1076#1080#1085#1077#1085#1080#1077
      Hint = #1056#1072#1079#1100#1077#1076#1080#1085#1077#1085#1080#1077' '#1089' '#1041#1044
      ImageIndex = 1
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actProjectEditLink: TAction
      Tag = 3
      Category = 'Project'
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1041#1044' ...'
      Hint = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1074#1103#1079#1080' '#1089' '#1041#1044
      ImageIndex = 2
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
    object actProjectYear: TAction
      Tag = 8
      Category = 'Project'
      Caption = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      Hint = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      OnExecute = ProjectActionExecute
      OnUpdate = ProjectActionUpdate
    end
    object actViewExamList: TAction
      Tag = 3
      Category = 'View'
      Caption = #1069#1082#1079#1072#1084#1077#1085#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      Hint = #1069#1082#1079#1072#1084#1077#1085#1099' '#1092#1072#1082#1091#1083#1100#1090#1077#1090#1072
      ImageIndex = 7
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actHelpTopics: TAction
      Tag = 1
      Category = 'Help'
      Caption = #1057#1087#1088#1072#1074#1082#1072': '#1055#1088#1086#1075#1088#1072#1084#1084#1072
      OnExecute = HelpActionExecute
      OnUpdate = HelpActionUpdate
    end
    object actHelpModule: TAction
      Tag = 2
      Category = 'Help'
      Caption = #1057#1087#1088#1072#1074#1082#1072': '#1052#1086#1076#1091#1083#1100
      Hint = #1057#1087#1088#1072#1074#1082#1072' '#1084#1086#1076#1091#1083#1103
      OnExecute = HelpActionExecute
      OnUpdate = HelpActionUpdate
    end
    object actViewExamKaf: TAction
      Tag = 4
      Category = 'View'
      Caption = #1069#1082#1079#1072#1084#1077#1085#1099' '#1082#1072#1092#1077#1076#1088#1099
      Hint = #1069#1082#1079#1072#1084#1077#1085#1099' '#1082#1072#1092#1077#1076#1088#1099
      ImageIndex = 8
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
    end
    object actViewLoadAud: TAction
      Tag = 5
      Category = 'View'
      Caption = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      Hint = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      ImageIndex = 9
      OnExecute = ViewActionExecute
      OnUpdate = ViewActionUpdate
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
      object mnuViewExams: TMenuItem
        Action = actViewExams
      end
      object mnuViewExamList: TMenuItem
        Action = actViewExamList
      end
      object mnuViewExamKaf: TMenuItem
        Action = actViewExamKaf
      end
      object mnuViewLoadAud: TMenuItem
        Action = actViewLoadAud
      end
      object N5: TMenuItem
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
  object MainImageList: TImageList
    Left = 580
    Top = 15
  end
end
