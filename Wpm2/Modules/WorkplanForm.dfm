object frmWorkplan: TfrmWorkplan
  Left = 189
  Top = 104
  ActiveControl = cxGrid
  AutoScroll = False
  Caption = #1056#1072#1073#1086#1095#1080#1081' '#1087#1083#1072#1085
  ClientHeight = 453
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid: TcxGrid
    Left = 0
    Top = 22
    Width = 688
    Height = 431
    Align = alClient
    TabOrder = 0
    object tvWorkplan: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      NavigatorButtons.First.Visible = False
      NavigatorButtons.PriorPage.Visible = False
      NavigatorButtons.Prior.Visible = True
      NavigatorButtons.Next.Visible = True
      NavigatorButtons.NextPage.Visible = False
      NavigatorButtons.Last.Visible = False
      NavigatorButtons.Insert.Visible = False
      NavigatorButtons.Edit.Visible = False
      NavigatorButtons.Post.Visible = True
      NavigatorButtons.Cancel.Visible = True
      NavigatorButtons.Refresh.Visible = False
      NavigatorButtons.SaveBookmark.Visible = False
      NavigatorButtons.GotoBookmark.Visible = False
      NavigatorButtons.Filter.Visible = False
      OnEditing = tvWorkplanEditing
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.Inserting = False
      OptionsSelection.InvertSelect = False
      OptionsView.Navigator = True
      OptionsView.GroupByBox = False
      OptionsView.NewItemRow = True
      OptionsView.NewItemRowInfoText = #1044#1086#1073#1072#1074#1080#1090#1100' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1091
      object tvWorkplanColumn1: TcxGridColumn
        Caption = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.ViewStyle = vsHideCursor
        Properties.OnButtonClick = tvWorkplanColumn1PropertiesButtonClick
        Width = 226
      end
      object tvWorkplanColumn2: TcxGridColumn
        Caption = #1050#1072#1092#1077#1076#1088#1072
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.ViewStyle = vsHideCursor
        Properties.OnButtonClick = tvWorkplanColumn2PropertiesButtonClick
        Width = 182
      end
      object tvWorkplanColumn3: TcxGridColumn
        Caption = #1069#1082#1079#1072#1084#1077#1085
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.Alignment = taCenter
        Properties.NullStyle = nssUnchecked
      end
    end
    object tvLoad: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      NavigatorButtons.First.Visible = False
      NavigatorButtons.PriorPage.Visible = False
      NavigatorButtons.NextPage.Visible = False
      NavigatorButtons.Last.Visible = False
      NavigatorButtons.Insert.Visible = False
      NavigatorButtons.Edit.Visible = False
      NavigatorButtons.Refresh.Visible = False
      NavigatorButtons.SaveBookmark.Visible = False
      NavigatorButtons.GotoBookmark.Visible = False
      NavigatorButtons.Filter.Visible = False
      OnEditing = tvLoadEditing
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.Inserting = False
      OptionsSelection.InvertSelect = False
      OptionsView.Navigator = True
      OptionsView.GroupByBox = False
      OptionsView.NewItemRow = True
      OptionsView.NewItemRowInfoText = #1044#1086#1073#1072#1074#1080#1090#1100' '#1072#1091#1076#1080#1090#1086#1088#1085#1091#1102' '#1085#1072#1075#1088#1091#1079#1082#1091
      object tvLoadColumn1: TcxGridColumn
        Caption = #1058#1080#1087' '#1079#1072#1085#1103#1090#1080#1103
        PropertiesClassName = 'TcxComboBoxProperties'
        Properties.DropDownListStyle = lsFixedList
        Properties.OnDrawItem = tvLoadColumn1PropertiesDrawItem
        Width = 100
      end
      object tvLoadColumn2: TcxGridColumn
        Caption = #1055#1088#1077#1087#1086#1076#1072#1074#1072#1090#1077#1083#1100
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ReadOnly = True
        Properties.ViewStyle = vsHideCursor
        Properties.OnButtonClick = tvLoadColumn2PropertiesButtonClick
        Width = 120
      end
      object tvLoadColumn3: TcxGridColumn
        Caption = #1055#1086#1090#1086#1082
      end
      object tvLoadColumn4: TcxGridColumn
        Caption = #1063#1072#1089#1099
      end
    end
    object lvlWorkplan: TcxGridLevel
      GridView = tvWorkplan
      object lvlLoad: TcxGridLevel
        GridView = tvLoad
      end
    end
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 22
    AutoSize = True
    EdgeBorders = []
    Flat = True
    Images = dmWork.BtnImageList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object btnWorkplanCopySbj: TToolButton
      Left = 0
      Top = 0
      Action = actWorkplanCopySbj
    end
    object btnWorkplanCopyGrp: TToolButton
      Left = 23
      Top = 0
      Action = actWorkplanCopyGrp
    end
    object btnWorkplanUpdate: TToolButton
      Left = 46
      Top = 0
      Action = actWorkplanUpdate
    end
  end
  object setWorkplan: TADODataSet
    Parameters = <>
    Left = 595
    Top = 85
  end
  object ActionList: TActionList
    Images = dmWork.BtnImageList
    Left = 595
    Top = 135
    object actWorkplanCopySbj: TAction
      Tag = 1
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1091
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1076#1080#1089#1094#1080#1087#1083#1080#1085#1091
      ImageIndex = 1
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actWorkplanCopyGrp: TAction
      Tag = 2
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1088#1072#1073'. '#1087#1083#1072#1085
      Hint = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1088#1072#1073#1086#1095#1080#1081' '#1087#1083#1072#1085
      ImageIndex = 2
      OnExecute = ActionsExecute
      OnUpdate = ActionsUpdate
    end
    object actWorkplanUpdate: TAction
      Tag = -1
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 0
      OnExecute = ActionsExecute
    end
  end
end
