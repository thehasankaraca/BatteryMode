﻿unit Brightness;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Win.Registry,
  System.Generics.Collections, System.Generics.Defaults;

type
  TBrightnessMonitorType = (bmtInternal, bmtExternal);
  TBrightnessMonitorManagementMethod = (
    bmmmTrayScroll = 1
  );
  TBrightnessMonitorManagementMethods = set of TBrightnessMonitorManagementMethod;
  TBrightnessLevels = TList<Byte>;

  // Интерфейсы
  IBrightnessMonitor = interface;
  IBrightnessProvider = interface;

  // Классы
  TBrightnessMonitorComparer = class;
  TBrightnessConfig = class;

  // Исключения
  TBrightnessMonitorException = class;

  TBrightnessChangeLevelEvent = procedure(Sender: IBrightnessMonitor; NewLevel: Integer) of object;
  TBrightnessChangeActiveEvent = procedure(Sender: IBrightnessMonitor; Active: Boolean) of object;
  TBrightnessChangeEnableEvent = procedure(Sender: IBrightnessMonitor; Enable: Boolean) of object;
  TBrightnessChangeAdaptiveBrightnessEvent = procedure(Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean) of object;
  TBrightnessChangeManagementMethodsEvent = procedure(Sender: IBrightnessMonitor; ManagementMethods: TBrightnessMonitorManagementMethods) of object;

  IBrightnessMonitor = interface
    function GetMonitorType: TBrightnessMonitorType;
    function GetDescription: string;
    function GetEnable: Boolean;
    procedure SetEnable(const Value: Boolean);
    function GetLevels: TBrightnessLevels;
    function GetLevel: Integer;
    procedure SetLevel(const Value: Integer);
    function GetNormalizedBrightness(Level: Integer): Byte;
    function GetUniqueString: string;
    function GetSlowMonitor: Boolean;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetAdaptiveBrightness: Boolean;
    procedure SetAdaptiveBrightness(const Value: Boolean);
    function GetAdaptiveBrightnessAvalible: Boolean;
    function GetManagementMethods: TBrightnessMonitorManagementMethods;
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);

    function GetOnChangeLevel: TBrightnessChangeLevelEvent;
    procedure SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
    function GetOnChangeActive: TBrightnessChangeActiveEvent;
    procedure SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
    function GetOnChangeEnable: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeEnable2: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    procedure SetOnChangeAdaptiveBrightness(const Value: TBrightnessChangeAdaptiveBrightnessEvent);
    function GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    procedure SetOnChangeManagementMethods(const Value: TBrightnessChangeManagementMethodsEvent);

    procedure LoadConfig(Config: TBrightnessConfig);
    function GetDefaultConfig: TBrightnessConfig;

    property MonitorType: TBrightnessMonitorType read GetMonitorType;
    property Description: string read GetDescription;
    property Enable: Boolean read GetEnable write SetEnable;
    property Levels: TBrightnessLevels read GetLevels;
    property Level: Integer read GetLevel write SetLevel;
    property NormalizedBrightness[Level: Integer]: Byte read GetNormalizedBrightness;
    property UniqueString: string read GetUniqueString;
    property SlowMonitor: Boolean read GetSlowMonitor;
    property Active: Boolean read GetActive write SetActive;
    property AdaptiveBrightness: Boolean read GetAdaptiveBrightness write SetAdaptiveBrightness;
    property AdaptiveBrightnessAvalible: Boolean read GetAdaptiveBrightnessAvalible;
    property ManagementMethods: TBrightnessMonitorManagementMethods read GetManagementMethods write SetManagementMethods;

    property OnChangeLevel: TBrightnessChangeLevelEvent read GetOnChangeLevel write SetOnChangeLevel;
    property OnChangeActive: TBrightnessChangeActiveEvent read GetOnChangeActive write SetOnChangeActive;
    property OnChangeEnable: TBrightnessChangeEnableEvent read GetOnChangeEnable write SetOnChangeEnable;
    property OnChangeEnable2: TBrightnessChangeEnableEvent read GetOnChangeEnable2 write SetOnChangeEnable2;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read GetOnChangeAdaptiveBrightness write SetOnChangeAdaptiveBrightness;
    property OnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent read GetOnChangeManagementMethods write SetOnChangeManagementMethods;
  end;

  TBrightnessMonitorComparer = class(TComparer<IBrightnessMonitor>)
  public
    function Compare(const Left, Right: IBrightnessMonitor): Integer; override;
  end;

  TBrightnessMonitorException = class(Exception)
  public
    constructor Create; overload;
  end;

  TProviderNeedUpdateEvent = procedure(Sender: IBrightnessProvider) of object;

  IBrightnessProvider = interface
    function GetMonitors: TList<IBrightnessMonitor>;
    function GetOnNeedUpdate: TProviderNeedUpdateEvent;
    procedure SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);

    function Load: TList<IBrightnessMonitor>;
    procedure Clean;

    property Monitors: TList<IBrightnessMonitor> read GetMonitors;
    property OnNeedUpdate: TProviderNeedUpdateEvent read GetOnNeedUpdate write SetOnNeedUpdate;
  end;

  TBrightnessConfig = class(TInterfacedObject)
  private const
    REG_Enable = 'Enabled';
    REG_Active = 'Active';
    REG_ManagementMethods = 'ManagementMethods';
  private
    FRootRegKey: string;
    FRegKey: string;

    FEnable: Boolean;
    FActive: Boolean;
    FManagementMethods: TBrightnessMonitorManagementMethods;
    procedure SetEnable(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);

    procedure LoadDefault(DefConfig: TBrightnessConfig);
    procedure SaveConfig;
  public
    constructor Create(RootRegKey: string; Monitor: IBrightnessMonitor); reintroduce; overload;
    constructor Create(Enable: Boolean; Active: Boolean; ManagementMethods: TBrightnessMonitorManagementMethods); reintroduce; overload;

    property Enable: Boolean read FEnable write SetEnable;
    property Active: Boolean read FActive write SetActive;
    property ManagementMethods: TBrightnessMonitorManagementMethods read FManagementMethods write SetManagementMethods;
  end;

  function NormalizeBrightness(Levels: TBrightnessLevels; Level: Integer): Byte;

implementation

function NormalizeBrightness(Levels: TBrightnessLevels; Level: Integer): Byte;
  function Max(a, b: Byte): Byte; inline;
  begin
    if a > b then Result := a else Result := b;
  end;
begin
  try
    Result := MulDiv(Levels[Level], 100, Max(Levels.First, Levels.Last));
  except
    Result := 255;
  end;
end;

{ TBrightnessMonitorComparer }

function TBrightnessMonitorComparer.Compare(const Left,
  Right: IBrightnessMonitor): Integer;
begin
  if Left.MonitorType = Right.MonitorType then
  begin
    Result := CompareText(Left.Description, Right.Description);
    if Result = 0 then
      Result := CompareText(Left.UniqueString, Right.UniqueString);
  end
  else
  begin
    if Left.MonitorType > Right.MonitorType then
      Exit(1)
    else if Left.MonitorType < Right.MonitorType then
      Exit(-1)
    else
      Exit(0);
  end;
end;

{ TBrightnessMonitorException }

constructor TBrightnessMonitorException.Create;
begin
  inherited Create(SysErrorMessage(GetLastError));
end;

{ TBrightnessConfig }

constructor TBrightnessConfig.Create(RootRegKey: string;
  Monitor: IBrightnessMonitor);
var
  Registry: TRegistry;
  DefConfig: TBrightnessConfig;

  function CleanupSpec(Str: string): string;
  var
    InvalidFileNameChars: TCharArray;
    Chr: Char;
  begin
    InvalidFileNameChars := TCharArray.Create(
      #0, #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12,
      #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24,
      #25, #26, #27, #28, #29, #30, #31,
      '"', '*', '/', ':', '<', '>', '?', '\', '|');

    Result := Str;
    for Chr in InvalidFileNameChars do
      Result := Result.Replace(Chr, '');
  end;

  function ReadBoolDef(const Name: string; const Def: Boolean): Boolean;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadBool(Name)
    else
      Result := Def;
  end;

  function ReadIntegerDef(const Name: string; const Def: Integer): Integer;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadInteger(Name)
    else
      Result := Def;
  end;

  function SetToInt(const aSet; const Size: Integer): Integer;
  begin
    Result := 0;
    Move(aSet, Result, Size);
  end;

  procedure IntToSet(const Value: Integer; var aSet; const Size: Integer);
  begin
    Move(Value, aSet, Size);
  end;
begin
  inherited Create;

  FRootRegKey := RootRegKey;
  FRegKey := FRootRegKey + PathDelim + CleanupSpec(Monitor.UniqueString);

  DefConfig := Monitor.GetDefaultConfig;
  LoadDefault(DefConfig);

  try
    Registry := TRegistry.Create;
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      if not Registry.KeyExists(FRegKey) then Exit;
      if not Registry.OpenKeyReadOnly(FRegKey) then Exit;

      // Read config
      FEnable := ReadBoolDef(REG_Enable, DefConfig.Enable);
      FActive := ReadBoolDef(REG_Active, DefConfig.Active);
      IntToSet(
        ReadIntegerDef(REG_ManagementMethods, SetToInt(DefConfig.ManagementMethods, SizeOf(FManagementMethods))),
        FManagementMethods,
        SizeOf(FManagementMethods));
      // end read config

      Registry.CloseKey;
    finally
      Registry.Free;
    end;
  finally
    Monitor.LoadConfig(Self);
  end;
end;

constructor TBrightnessConfig.Create(Enable, Active: Boolean; ManagementMethods: TBrightnessMonitorManagementMethods);
begin
  inherited Create;

  FEnable := Enable;
  FActive := Active;
  FManagementMethods := ManagementMethods;
end;

procedure TBrightnessConfig.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  FEnable := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;

  FActive := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);
begin
  if FManagementMethods = Value then Exit;

  FManagementMethods := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SaveConfig;
var
  Registry: TRegistry;

  function SetToInt(const aSet; const Size: Integer): Integer;
  begin
    Result := 0;
    Move(aSet, Result, Size);
  end;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(FRegKey);
    if Registry.OpenKey(FRegKey, True) then begin
      // Write config
      Registry.WriteBool(REG_Enable, FEnable);
      Registry.WriteBool(REG_Active, FActive);
      Registry.WriteInteger(REG_ManagementMethods, SetToInt(FManagementMethods, SizeOf(FManagementMethods)));
      // end write config

      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TBrightnessConfig.LoadDefault(DefConfig: TBrightnessConfig);
begin
  FEnable := DefConfig.Enable;
  FActive := DefConfig.Active;
  FManagementMethods := DefConfig.ManagementMethods;
end;

end.
