object frmBrowser: TfrmBrowser
  Left = 246
  Top = 102
  Width = 236
  Height = 344
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object CaptionLabel: TLabel
    Left = 0
    Top = 0
    Width = 228
    Height = 18
    Align = alTop
    AutoSize = False
    Caption = ' '#1057#1090#1088#1091#1082#1090#1091#1088#1072
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
  object TreeView: TTreeView
    Left = 0
    Top = 18
    Width = 228
    Height = 299
    Align = alClient
    DragMode = dmAutomatic
    Images = TreeList
    Indent = 19
    ParentShowHint = False
    PopupMenu = PopupMenu
    ReadOnly = True
    RightClickSelect = True
    ShowHint = True
    TabOrder = 0
    OnDblClick = TreeViewDblClick
    OnDeletion = TreeViewDeletion
    OnExpanding = TreeViewExpanding
    OnGetImageIndex = TreeViewGetImageIndex
    OnMouseUp = TreeViewMouseUp
  end
  object ActionList: TActionList
    Images = TreeList
    Left = 155
    Top = 35
    object actSelect: TAction
      Tag = 1
      Caption = #1042#1099#1073#1088#1072#1090#1100
      Hint = #1042#1099#1073#1088#1072#1090#1100
      ShortCut = 13
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actUpdate: TAction
      Tag = 2
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ShortCut = 116
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
  end
  object TreeList: TImageList
    Left = 155
    Top = 85
  end
  object PopupMenu: TPopupMenu
    Left = 155
    Top = 135
    object mnuSelect: TMenuItem
      Action = actSelect
      Default = True
    end
    object mnuUpdate: TMenuItem
      Action = actUpdate
    end
  end
end
