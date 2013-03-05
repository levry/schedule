inherited dmImport: TdmImport
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  Left = 312
  Top = 170
  Height = 382
  Width = 477
  object spImport2: TADOCommand
    CommandText = 'prc_Import2;1'
    CommandType = cmdStoredProc
    Connection = Connection
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@case'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@ynum'
        Attributes = [paNullable]
        DataType = ftSmallint
        Precision = 5
        Value = Null
      end
      item
        Name = '@fid'
        Attributes = [paNullable]
        DataType = ftInteger
        Direction = pdInputOutput
        Precision = 10
        Value = Null
      end
      item
        Name = '@kid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end
      item
        Name = '@grid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end
      item
        Name = '@sbid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end
      item
        Name = '@wpid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end
      item
        Name = '@lid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end
      item
        Name = '@fName'
        Attributes = [paNullable]
        DataType = ftString
        Size = 80
        Value = Null
      end
      item
        Name = '@kName'
        Attributes = [paNullable]
        DataType = ftString
        Size = 150
        Value = Null
      end
      item
        Name = '@grName'
        Attributes = [paNullable]
        DataType = ftString
        Size = 10
        Value = Null
      end
      item
        Name = '@sbName'
        Attributes = [paNullable]
        DataType = ftString
        Size = 100
        Value = Null
      end
      item
        Name = '@studs'
        Attributes = [paNullable]
        DataType = ftSmallint
        Precision = 5
        Value = Null
      end
      item
        Name = '@course'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@sem'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@sbCode'
        Attributes = [paNullable]
        DataType = ftString
        Size = 20
        Value = Null
      end
      item
        Name = '@WP1'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@WP2'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@TotalHLP'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@TotalAHLP'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@Compl'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@Kp'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@Kr'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@Rg'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@Cr'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@Hr'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@Koll'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@z'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@e'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@psem'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@type'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@hours'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end>
    Left = 175
    Top = 15
  end
  object GroupTable: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <
      item
        Name = 'RecState'
        DataType = ftWord
      end
      item
        Name = 'grid'
        DataType = ftLargeint
      end
      item
        Name = 'grName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 10
      end
      item
        Name = 'kid'
        DataType = ftLargeint
      end
      item
        Name = 'kName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 50
      end
      item
        Name = 'studs'
        Attributes = [faRequired]
        DataType = ftSmallint
      end
      item
        Name = 'course'
        Attributes = [faRequired]
        DataType = ftWord
      end
      item
        Name = 'chkyear'
        DataType = ftBoolean
      end
      item
        Name = 'ynum'
        Attributes = [faRequired]
        DataType = ftSmallint
      end
      item
        Name = 'flags'
        DataType = ftWord
      end>
    IndexDefs = <
      item
        Name = 'Group_NameIndex'
        Fields = 'grName'
        Options = [ixUnique, ixCaseInsensitive]
      end>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = False
    SavedCompletely = False
    FilterOptions = []
    Version = '5.50'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    AfterPost = MemoryTableAfterPost
    BeforeDelete = GroupTableBeforeDelete
    Left = 295
    Top = 15
    object Group_RecState: TWordField
      DisplayLabel = '[RecState]'
      FieldName = 'RecState'
    end
    object Group_grid: TLargeintField
      DisplayLabel = '[grid]'
      FieldName = 'grid'
    end
    object Group_grName: TStringField
      DisplayLabel = #1053#1072#1079#1074#1072#1085#1080#1077
      FieldName = 'grName'
      Required = True
      Size = 10
    end
    object Group_kid: TLargeintField
      DisplayLabel = '[kid]'
      FieldName = 'kid'
    end
    object Group_kName: TStringField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      FieldName = 'kName'
      Required = True
      Size = 50
    end
    object Group_studs: TSmallintField
      DisplayLabel = #1050#1086#1085#1090#1080#1085#1075#1077#1085#1090
      FieldName = 'studs'
      Required = True
    end
    object Group_course: TWordField
      DisplayLabel = #1050#1091#1088#1089
      FieldName = 'course'
      Required = True
    end
    object Group_chkyear: TBooleanField
      DisplayLabel = '[chkyear]'
      FieldName = 'chkyear'
    end
    object Group_ynum: TSmallintField
      DisplayLabel = #1059#1095'. '#1075#1086#1076
      FieldName = 'ynum'
      Required = True
    end
    object Group_flags: TWordField
      DisplayLabel = '[flags]'
      FieldName = 'flags'
    end
  end
  object WorkplanTable: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <
      item
        Name = 'wpid'
        DataType = ftLargeint
      end
      item
        Name = 'grid'
        DataType = ftLargeint
      end
      item
        Name = 'grName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 10
      end
      item
        Name = 'sbid'
        DataType = ftLargeint
      end
      item
        Name = 'sbName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 100
      end
      item
        Name = 'kid'
        DataType = ftLargeint
      end
      item
        Name = 'kName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 50
      end
      item
        Name = 'Sem'
        Attributes = [faRequired]
        DataType = ftWord
      end
      item
        Name = 'sbCode'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'WP1'
        DataType = ftWord
      end
      item
        Name = 'WP2'
        DataType = ftWord
      end
      item
        Name = 'TotalHLP'
        DataType = ftInteger
      end
      item
        Name = 'TotalAHLP'
        DataType = ftInteger
      end
      item
        Name = 'Compl'
        DataType = ftInteger
      end
      item
        Name = 'Lec1'
        DataType = ftWord
      end
      item
        Name = 'Prc1'
        DataType = ftWord
      end
      item
        Name = 'Lab1'
        DataType = ftWord
      end
      item
        Name = 'Lec2'
        DataType = ftWord
      end
      item
        Name = 'Prc2'
        DataType = ftWord
      end
      item
        Name = 'Lab2'
        DataType = ftWord
      end
      item
        Name = 'Kp'
        DataType = ftWord
      end
      item
        Name = 'Kr'
        DataType = ftWord
      end
      item
        Name = 'Rg'
        DataType = ftWord
      end
      item
        Name = 'Cr'
        DataType = ftWord
      end
      item
        Name = 'Hr'
        DataType = ftWord
      end
      item
        Name = 'Koll'
        DataType = ftWord
      end
      item
        Name = 'Z'
        DataType = ftWord
      end
      item
        Name = 'E'
        DataType = ftWord
      end>
    IndexFieldNames = 'grName;sbName;Sem'
    IndexName = 'Workplan_Index'
    IndexDefs = <
      item
        Name = 'Workplan_Index'
        Fields = 'grName;sbName;Sem'
        Options = [ixUnique, ixCaseInsensitive]
      end>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = False
    SavedCompletely = False
    FilterOptions = []
    MasterFields = 'grName'
    DetailFields = 'grName'
    MasterSource = GroupSource
    Version = '5.50'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    AfterPost = MemoryTableAfterPost
    Left = 295
    Top = 65
    object Workplan_RecState: TWordField
      DisplayLabel = '[RecState]'
      FieldName = 'RecState'
    end
    object Workplan_wpid: TLargeintField
      DisplayLabel = '[wpid]'
      FieldName = 'wpid'
    end
    object Workplan_grid: TLargeintField
      DisplayLabel = '[grid]'
      FieldName = 'grid'
    end
    object Workplan_grName: TStringField
      DisplayLabel = '[grName]'
      FieldName = 'grName'
      Required = True
      Size = 10
    end
    object Workplan_sbid: TLargeintField
      DisplayLabel = '[sbid]'
      FieldName = 'sbid'
    end
    object Workplan_sbName: TStringField
      DisplayLabel = #1044#1080#1089#1094#1080#1087#1083#1080#1085#1072
      FieldName = 'sbName'
      Required = True
      Size = 100
    end
    object Workplan_kid: TLargeintField
      DisplayLabel = '[kid]'
      FieldName = 'kid'
    end
    object Workplan_kName: TStringField
      DisplayLabel = #1050#1072#1092#1077#1076#1088#1072
      FieldName = 'kName'
      Required = True
      Size = 150
    end
    object Workplan_Sem: TWordField
      DisplayLabel = '[Sem]'
      FieldName = 'Sem'
      Required = True
    end
    object Workplan_sbCode: TStringField
      DisplayLabel = #1048#1085#1076#1077#1082#1089
      FieldName = 'sbCode'
    end
    object Workplan_WP1: TWordField
      FieldName = 'WP1'
    end
    object Workplan_WP2: TWordField
      FieldName = 'WP2'
    end
    object Workplan_TotalHLP: TIntegerField
      DisplayLabel = #1042#1089#1077#1075#1086' '#1087#1086' '#1091#1095'. '#1087#1083#1072#1085#1091
      FieldName = 'TotalHLP'
    end
    object Workplan_TotalAHLP: TIntegerField
      DisplayLabel = #1042#1089#1077#1075#1086' '#1072#1091#1076#1080#1090#1086#1088'. '#1095#1072#1089#1086#1074
      FieldName = 'TotalAHLP'
    end
    object Workplan_Compl: TIntegerField
      DisplayLabel = #1055#1088#1086#1081#1076#1077#1085#1086' '#1088#1072#1085#1077#1077
      FieldName = 'Compl'
    end
    object Workplan_Lec1: TWordField
      DisplayLabel = #1051#1077#1082#1094#1080#1080
      FieldName = 'Lec1'
    end
    object Workplan_Prc1: TWordField
      DisplayLabel = #1055#1088#1072#1082#1090'.'
      FieldName = 'Prc1'
    end
    object Workplan_Lab1: TWordField
      DisplayLabel = #1051#1072#1073'.'
      FieldName = 'Lab1'
    end
    object Workplan_Lec2: TWordField
      FieldName = 'Lec2'
    end
    object Workplan_Prc2: TWordField
      FieldName = 'Prc2'
    end
    object Workplan_Lab2: TWordField
      FieldName = 'Lab2'
    end
    object Workplan_Kp: TWordField
      DisplayLabel = #1050#1091#1088#1089#1086#1074#1099#1077' '#1087#1088#1086#1077#1082#1090#1099
      FieldName = 'Kp'
    end
    object Workplan_Kr: TWordField
      DisplayLabel = #1050#1091#1088#1089#1086#1074#1099#1077' '#1088#1072#1073#1086#1090#1099
      FieldName = 'Kr'
    end
    object Workplan_Rg: TWordField
      DisplayLabel = #1056#1072#1089#1095#1077#1090'.-'#1075#1088#1072#1092'. '#1088#1072#1073#1086#1090#1099
      FieldName = 'Rg'
    end
    object Workplan_Cr: TWordField
      DisplayLabel = #1050#1086#1085#1090#1088#1086#1083#1100#1085#1099#1077' '#1088#1072#1073#1086#1090#1099
      FieldName = 'Cr'
    end
    object Workplan_Hr: TWordField
      DisplayLabel = #1044#1086#1084#1072#1096#1085#1080#1077' '#1088#1072#1073#1086#1090#1099
      FieldName = 'Hr'
    end
    object Workplan_Koll: TWordField
      DisplayLabel = #1050#1086#1083#1083#1086#1082#1074#1080#1091#1084#1099
      FieldName = 'Koll'
    end
    object Workplan_Z: TWordField
      DisplayLabel = #1047#1072#1095#1077#1090
      FieldName = 'Z'
    end
    object Workplan_E: TWordField
      DisplayLabel = #1069#1082#1079#1072#1084#1077#1085
      FieldName = 'E'
    end
  end
  object WorkplanSource: TDataSource
    DataSet = WorkplanTable
    Left = 375
    Top = 65
  end
  object GroupSource: TDataSource
    DataSet = GroupTable
    Left = 375
    Top = 15
  end
  object spSubjMgm: TADOCommand
    CommandText = 'prc_SubjMgm;1'
    CommandType = cmdStoredProc
    Connection = Connection
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@case'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@letter'
        Attributes = [paNullable]
        DataType = ftString
        Size = 1
        Value = Null
      end
      item
        Name = '@sbid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@new'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end>
    Left = 110
    Top = 65
  end
  object spDBView: TADOCommand
    CommandText = 'prc_DBView;1'
    CommandType = cmdStoredProc
    Connection = Connection
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = -100
      end
      item
        Name = '@case'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@ynum'
        Attributes = [paNullable]
        DataType = ftSmallint
        Precision = 5
        Value = Null
      end
      item
        Name = '@sem'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@fid'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@kid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@grid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@sbid'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@letter'
        Attributes = [paNullable]
        DataType = ftString
        Size = 1
        Value = Null
      end
      item
        Name = '@course'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end>
    Left = 110
    Top = 15
  end
  object LogTable: TkbmMemTable
    DesignActivation = True
    AttachedAutoRefresh = True
    AttachMaxCount = 1
    FieldDefs = <
      item
        Name = 'MsgType'
        DataType = ftInteger
      end
      item
        Name = 'Msg'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'xSet'
        DataType = ftSmallint
      end
      item
        Name = 'grName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 10
      end
      item
        Name = 'sem'
        Attributes = [faRequired]
        DataType = ftWord
      end
      item
        Name = 'sbName'
        Attributes = [faRequired]
        DataType = ftString
        Size = 100
      end
      item
        Name = 'xValue'
        Attributes = [faRequired]
        DataType = ftString
        Size = 50
      end>
    IndexDefs = <>
    SortOptions = []
    PersistentBackup = False
    ProgressFlags = [mtpcLoad, mtpcSave, mtpcCopy]
    LoadedCompletely = False
    SavedCompletely = False
    FilterOptions = []
    Version = '5.50'
    LanguageID = 0
    SortID = 0
    SubLanguageID = 1
    LocaleID = 1024
    Left = 295
    Top = 115
    object Log_MsgType: TIntegerField
      Alignment = taLeftJustify
      DisplayLabel = #1058#1080#1087
      FieldName = 'MsgType'
    end
    object Log_Msg: TStringField
      DisplayLabel = #1057#1086#1086#1073#1097#1077#1085#1080#1077
      FieldName = 'Msg'
      OnGetText = Log_MsgGetText
      Size = 200
    end
    object Log_xSet: TSmallintField
      DisplayLabel = '[xSet]'
      FieldName = 'xSet'
    end
    object Log_grName: TStringField
      DisplayLabel = #1043#1088#1091#1087#1087#1072
      FieldName = 'grName'
      Size = 10
    end
    object Log_sem: TWordField
      DisplayLabel = '[sem]'
      FieldName = 'sem'
    end
    object Log_xValue: TStringField
      DisplayLabel = '[sbName]'
      FieldName = 'sbName'
      Size = 100
    end
    object LogTablekName: TStringField
      DisplayLabel = '[xValue]'
      FieldName = 'xValue'
      Required = True
      Size = 50
    end
  end
  object LogSource: TDataSource
    DataSet = LogTable
    Left = 375
    Top = 115
  end
end
