object Form4: TForm4
  Left = 0
  Top = 0
  ClientHeight = 510
  ClientWidth = 1029
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    1029
    510)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 700
    Top = 11
    Width = 65
    Height = 13
    Alignment = taRightJustify
    Caption = 'Access Code:'
  end
  object Label2: TLabel
    Left = 732
    Top = 38
    Width = 33
    Height = 13
    Alignment = taRightJustify
    Caption = 'Token:'
  end
  object Label3: TLabel
    Left = 694
    Top = 65
    Width = 71
    Height = 13
    Alignment = taRightJustify
    Caption = 'RefreshToken:'
  end
  object Label4: TLabel
    Left = 984
    Top = 97
    Width = 37
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'Label4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 12
    Top = 11
    Width = 65
    Height = 13
    Alignment = taRightJustify
    Caption = 'Callback URL:'
  end
  object Label6: TLabel
    Left = 25
    Top = 38
    Width = 52
    Height = 13
    Alignment = taRightJustify
    Caption = 'Username:'
  end
  object Label7: TLabel
    Left = 16
    Top = 65
    Width = 61
    Height = 13
    Alignment = taRightJustify
    Caption = 'Client Secret'
  end
  object Label8: TLabel
    Left = 28
    Top = 89
    Width = 49
    Height = 13
    Alignment = taRightJustify
    Caption = 'Ambiente:'
  end
  object Button1: TButton
    Left = 575
    Top = 8
    Width = 95
    Height = 36
    Caption = 'GetToken'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 463
    Top = 8
    Width = 106
    Height = 36
    Caption = 'Login'
    TabOrder = 1
    OnClick = Button2Click
  end
  object edCode: TEdit
    Left = 771
    Top = 8
    Width = 250
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object edToken: TEdit
    Left = 771
    Top = 35
    Width = 250
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 3
  end
  object edRefreshToken: TEdit
    Left = 771
    Top = 62
    Width = 250
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 4
  end
  object Button3: TButton
    Left = 463
    Top = 50
    Width = 207
    Height = 27
    Caption = 'UploadFile'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 116
    Width = 1013
    Height = 386
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 6
  end
  object edCallbackURL: TEdit
    Left = 83
    Top = 8
    Width = 350
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 7
  end
  object edUsername: TEdit
    Left = 83
    Top = 35
    Width = 350
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 8
  end
  object edPassword: TEdit
    Left = 83
    Top = 62
    Width = 350
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 9
  end
  object cbAmbiente: TComboBox
    Left = 83
    Top = 89
    Width = 350
    Height = 21
    Style = csDropDownList
    TabOrder = 10
    Items.Strings = (
      'Produ'#231#227'o'
      'Homologa'#231#227'o')
  end
  object Button4: TButton
    Left = 463
    Top = 83
    Width = 207
    Height = 27
    Caption = 'StatusFile'
    TabOrder = 11
    OnClick = Button4Click
  end
  object OpenDialog1: TOpenDialog
    Left = 392
    Top = 184
  end
end
