object frmMain: TfrmMain
  Left = 315
  Top = 263
  Width = 709
  Height = 477
  Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077
  Color = clAppWorkSpace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
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
    Width = 5
    Height = 390
    Color = clBtnFace
    ParentColor = False
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 412
    Width = 701
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
  object ContainerPanel: TPanel
    Left = 190
    Top = 22
    Width = 511
    Height = 390
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object CaptionLabel: TLabel
      Left = 0
      Top = 0
      Width = 511
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
      Top = 369
      Width = 511
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
      TabStop = False
      OnChange = TabControlChange
    end
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 701
    Height = 22
    AutoSize = True
    Caption = 'ToolBar'
    Color = clBtnFace
    EdgeBorders = []
    Flat = True
    Images = MainImageList
    ParentColor = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
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
    object ToolButton1: TToolButton
      Left = 72
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnViewAuditory: TToolButton
      Left = 80
      Top = 0
      Action = actViewAuditory
    end
    object btnViewTeachers: TToolButton
      Left = 103
      Top = 0
      Action = actViewTeacher
    end
    object btnViewSchedule: TToolButton
      Left = 126
      Top = 0
      Action = actViewSchedule
    end
    object btnViewTeacherTime: TToolButton
      Left = 149
      Top = 0
      Action = actViewTeacherTime
    end
    object btnViewAuditoryTime: TToolButton
      Left = 172
      Top = 0
      Action = actViewAuditoryTime
    end
    object btnViewAuditoryLoad: TToolButton
      Left = 195
      Top = 0
      Action = actViewAuditoryLoad
    end
  end
  object BrowserPanel: TPanel
    Left = 0
    Top = 22
    Width = 185
    Height = 390
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MinWidth = 50
    TabOrder = 3
    Visible = False
  end
  object MainMenu: TMainMenu
    Images = MainImageList
    Left = 525
    Top = 65
    object mnuProject: TMenuItem
      Caption = #1055#1088#1086#1077#1082#1090
      object mnuProjectYear: TMenuItem
        Action = actProjectYear
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuProjectConnect: TMenuItem
        Action = actProjectConnect
      end
      object mnuProjectDisconnect: TMenuItem
        Action = actProjectDisconect
      end
      object mnuProjectEditLink: TMenuItem
        Action = actProjectEditLink
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mnuProjectClose: TMenuItem
        Action = actProjectExit
      end
    end
    object mnuView: TMenuItem
      Caption = #1042#1080#1076
      object mnuViewAuditory: TMenuItem
        Action = actViewAuditory
      end
      object mnuViewTeachers: TMenuItem
        Action = actViewTeacher
      end
      object mnuViewSchedule: TMenuItem
        Action = actViewSchedule
      end
      object mnuViewTeacherTime: TMenuItem
        Action = actViewTeacherTime
      end
      object mnuViewAuditoryTime: TMenuItem
        Action = actViewAuditoryTime
      end
      object mnuViewAuditoryLoad: TMenuItem
        Action = actViewAuditoryLoad
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mnuViewUpdate: TMenuItem
        Action = actViewUpdate
      end
    end
    object mnuService: TMenuItem
      Caption = #1057#1077#1088#1074#1080#1089
      object mnuServiceExport: TMenuItem
        Action = actServiceExport
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
  object ActionList: TActionList
    Images = MainImageList
    Left = 526
    Top = 15
    object actViewPSem: TAction
      Tag = -3
      Category = 'View'
      Caption = #1055#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      Hint = #1055#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actProjectExit: TAction
      Tag = -1
      Category = 'Project'
      Caption = #1042#1099#1093#1086#1076
      Hint = #1042#1099#1093#1086#1076' '#1080#1079' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
      OnExecute = ProjectActionsExecute
    end
    object actProjectFirstSem: TAction
      Tag = 1
      Category = 'Project'
      Caption = #1054#1089#1077#1085#1085#1080#1081
      ImageIndex = 3
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectSecondSem: TAction
      Tag = 2
      Category = 'Project'
      Caption = #1042#1077#1089#1077#1085#1085#1080#1081
      ImageIndex = 4
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectFirstPSem: TAction
      Tag = 3
      Category = 'Project'
      Caption = '1 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      ImageIndex = 5
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actProjectSecondPSem: TAction
      Tag = 4
      Category = 'Project'
      Caption = '2 '#1087#1086#1083#1091#1089#1077#1084#1077#1089#1090#1088
      ImageIndex = 6
      OnExecute = SemActionExecute
      OnUpdate = SemActionUpdate
    end
    object actViewSem: TAction
      Tag = -2
      Category = 'View'
      Caption = #1057#1077#1084#1077#1089#1090#1088
      Hint = #1057#1077#1084#1077#1089#1090#1088
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actViewUpdate: TAction
      Tag = -1
      Category = 'View'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1090#1077#1082#1091#1097#1077#1077' '#1086#1082#1085#1086
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actViewAuditory: TAction
      Tag = 1
      Category = 'View'
      Caption = #1040#1091#1076#1080#1090#1086#1088#1080#1080
      Hint = #1040#1091#1076#1080#1090#1086#1088#1080#1080
      ImageIndex = 7
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actViewTeacher: TAction
      Tag = 2
      Category = 'View'
      Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1080
      Hint = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1080
      ImageIndex = 8
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actViewSchedule: TAction
      Tag = 3
      Category = 'View'
      Caption = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077
      Hint = #1056#1072#1089#1087#1080#1089#1072#1085#1080#1077
      ImageIndex = 10
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actServiceExport: TAction
      Tag = 2
      Category = 'Service'
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1079#1072#1103#1074#1086#1082
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1079#1072#1103#1074#1086#1082' '#1074' Excel '#1092#1072#1081#1083
      OnExecute = ServiceActionsExecute
      OnUpdate = ServiceActionsUpdate
    end
    object actProjectConnect: TAction
      Tag = 5
      Category = 'Project'
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077
      ImageIndex = 1
      OnExecute = ProjectActionsExecute
      OnUpdate = ProjectActionsUpdate
    end
    object actProjectDisconect: TAction
      Tag = 6
      Category = 'Project'
      Caption = #1056#1072#1079#1100#1077#1076#1080#1085#1077#1085#1080#1077
      ImageIndex = 2
      OnExecute = ProjectActionsExecute
      OnUpdate = ProjectActionsUpdate
    end
    object actProjectEditLink: TAction
      Tag = 7
      Category = 'Project'
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1041#1044'...'
      OnExecute = ProjectActionsExecute
      OnUpdate = ProjectActionsUpdate
    end
    object actViewTeacherTime: TAction
      Tag = 4
      Category = 'View'
      Caption = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1077#1081
      Hint = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1087#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1077#1081
      ImageIndex = 11
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actViewAuditoryTime: TAction
      Tag = 5
      Category = 'View'
      Caption = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      Hint = #1047#1072#1085#1103#1090#1086#1089#1090#1100' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      ImageIndex = 12
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
    end
    object actProjectYear: TAction
      Tag = 8
      Category = 'Project'
      Caption = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      Hint = #1059#1095#1077#1073#1085#1099#1081' '#1075#1086#1076
      OnExecute = ProjectActionsExecute
      OnUpdate = ProjectActionsUpdate
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
    object actViewAuditoryLoad: TAction
      Tag = 6
      Category = 'View'
      Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      Hint = #1047#1072#1075#1088#1091#1079#1082#1072' '#1072#1091#1076#1080#1090#1086#1088#1080#1081
      ImageIndex = 13
      OnExecute = ViewActionsExecute
      OnUpdate = ViewActionsUpdate
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
    Left = 595
    Top = 17
  end
end
