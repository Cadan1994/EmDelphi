object DM: TDM
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 181
  Width = 351
  object ADOConnection: TADOConnection
    Left = 48
    Top = 24
  end
  object ADOQuery1: TADOQuery
    Parameters = <>
    Left = 136
    Top = 24
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Port=2899'
      'MetaDefSchema=cadan'
      'DriverID=PG'
      'Server=172.16.157.3')
    LoginPrompt = False
    Left = 48
    Top = 88
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    Left = 144
    Top = 88
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      '')
    Left = 240
    Top = 88
  end
end
