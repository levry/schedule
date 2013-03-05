object frmPreferDlg: TfrmPreferDlg
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = '[ '#1054#1075#1088#1072#1085#1080#1095#1077#1085#1080#1077' ]'
  ClientHeight = 200
  ClientWidth = 200
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
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  DesignSize = (
    200
    200)
  PixelsPerInch = 96
  TextHeight = 13
  object OkBtn: TButton
    Left = 35
    Top = 170
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 120
    Top = 170
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
end
