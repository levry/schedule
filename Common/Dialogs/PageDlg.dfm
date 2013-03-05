object frmPageDlg: TfrmPageDlg
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  ClientHeight = 350
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    300
    350)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 140
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 220
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControl: TPageControl
    Left = 5
    Top = 5
    Width = 289
    Height = 306
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
  end
end
