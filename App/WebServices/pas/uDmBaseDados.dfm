object fDmBaseDados: TfDmBaseDados
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 512
  Width = 313
  object connConcinco: TADOConnection
    Left = 104
    Top = 16
  end
  object connAplicativo: TFDConnection
    Params.Strings = (
      'Port=2899'
      'MetaDefSchema=cadan'
      'DriverID=PG'
      'Server=172.16.157.3')
    LoginPrompt = False
    Left = 104
    Top = 128
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    Left = 104
    Top = 176
  end
  object connMaxima: TADOConnection
    Left = 104
    Top = 72
  end
end
