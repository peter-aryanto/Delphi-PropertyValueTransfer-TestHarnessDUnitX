unit DomainNameHere.Helper;

interface

uses
  Data.DB
  , Spring.Collections
  , Spring
  ;

type
  {$M+}
  // Not yet used.
  IDataSetValueExtractor = interface
    ['{B73CA086-ECE7-46CC-93B0-0C18DDFE5419}']
    function GetDataSetField(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True
    ): TField;
    function GetStringValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: string = ''
    ): string; overload;
    function GetIntegerValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: Integer = 0
    ): Integer; overload;
    function GetDateValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: TDate = 0
    ): TDate; overload;
  end;

  IPropertyValueTransferrer = interface
    ['{784D51BE-FC42-4432-BE23-EAE13D1248A3}']
    procedure TransferValuesBasedOnSameCaseInsensitivePropertyName(
      const ASourceObjectWithSameCaseInsensitivePropertyName: TObject;
      const ATargetObjectWithSameCaseInsensitivePropertyName: TObject
    );
    procedure TransferValuesBasedOnPropertyNameMapping(
      const APropertyNameMapping: IList<Tuple<string, string>>;
      const ASourceObject: TObject;
      const ATargetObject: TObject
    );
  end;
  {$M-}

  // Not yet used.
  TDataSetValueExtractor = class(TInterfacedObject, IDataSetValueExtractor)
  public
    function GetDataSetField(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True
    ): TField;
    function GetStringValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: string = ''
    ): string; overload;
    function GetIntegerValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: Integer = 0
    ): Integer; overload;
    function GetDateValueFromDataSet(
      const ADataSet: TDataSet;
      const AFieldName: string;
      const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
      const ADefaultValue: TDate = 0
    ): TDate; overload;
  end;

  TPropertyValueTransferrer = class(TInterfacedObject, IPropertyValueTransferrer)
  public
    procedure TransferValuesBasedOnSameCaseInsensitivePropertyName(
      const ASourceObjectWithSameCaseInsensitivePropertyName: TObject;
      const ATargetObjectWithSameCaseInsensitivePropertyName: TObject
    );
    procedure TransferValuesBasedOnPropertyNameMapping(
      const APropertyNameMapping: IList<Tuple<string, string>>;
      const ASourceObject: TObject;
      const ATargetObject: TObject
    );
  end;

implementation

uses
  System.SysUtils
  , System.Rtti
  ;

{ TDataSetValueExtractor }

function TDataSetValueExtractor.GetDataSetField(
  const ADataSet: TDataSet;
  const AFieldName: string;
  const AIsRaisingExceptionWhenFieldNotExist: Boolean = True
): TField;
begin
  try
    Result := ADataSet.FieldByName(AFieldName);
  except
    on E: EDatabaseError do
    begin
      if AIsRaisingExceptionWhenFieldNotExist then
        raise
      else
        Result := nil;
    end;
  end;
end;

function TDataSetValueExtractor.GetStringValueFromDataSet(
  const ADataSet: TDataSet;
  const AFieldName: string;
  const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
  const ADefaultValue: string = ''
): string;
var
  LField: TField;
begin
  LField := GetDataSetField(ADataSet, AFieldName, AIsRaisingExceptionWhenFieldNotExist);
  if LField <> nil then
    Result := LField.AsString
  else
    Result := ADefaultValue;
end;

function TDataSetValueExtractor.GetIntegerValueFromDataSet(
  const ADataSet: TDataSet;
  const AFieldName: string;
  const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
  const ADefaultValue: Integer = 0
): Integer;
var
  LField: TField;
begin
  LField := GetDataSetField(ADataSet, AFieldName, AIsRaisingExceptionWhenFieldNotExist);
  if LField <> nil then
    Result := LField.AsInteger
  else
    Result := ADefaultValue;
end;

function TDataSetValueExtractor.GetDateValueFromDataSet(
  const ADataSet: TDataSet;
  const AFieldName: string;
  const AIsRaisingExceptionWhenFieldNotExist: Boolean = True;
  const ADefaultValue: TDate = 0
): TDate;
var
  LField: TField;
begin
  LField := GetDataSetField(ADataSet, AFieldName, AIsRaisingExceptionWhenFieldNotExist);
  if LField <> nil then
    Result := LField.AsDateTime
  else
    Result := ADefaultValue;
end;

{ TPropertyValueTransferrer }

procedure TPropertyValueTransferrer.TransferValuesBasedOnSameCaseInsensitivePropertyName(
  const ASourceObjectWithSameCaseInsensitivePropertyName: TObject;
  const ATargetObjectWithSameCaseInsensitivePropertyName: TObject
);
const
  CThisProcess = 'property-name-based value transferrer';
var
  LRttiContextRecord: TRttiContext;
  LSourceObjectRttiClass: TRttiType;
  LTargetObjectRttiClass: TRttiType;
  LTargetRttiPropertyArray: TArray<TRttiProperty>;
  LTargetRttiProperty: TRttiProperty;
  LSourceRttiProperty: TRttiProperty;
begin
  if not Assigned(ASourceObjectWithSameCaseInsensitivePropertyName) then
    raise Exception.Create('The ' + CThisProcess + ' is missing the source object.');
  if not Assigned(ATargetObjectWithSameCaseInsensitivePropertyName) then
    raise Exception.Create('The ' + CThisProcess + ' is missing the target object.');

  LSourceObjectRttiClass :=
    LRttiContextRecord.GetType(ASourceObjectWithSameCaseInsensitivePropertyName.ClassType);
  LTargetObjectRttiClass :=
    LRttiContextRecord.GetType(ATargetObjectWithSameCaseInsensitivePropertyName.ClassType);

  LTargetRttiPropertyArray := LTargetObjectRttiClass.GetProperties;
  for LTargetRttiProperty in LTargetRttiPropertyArray do
  begin
    LSourceRttiProperty := LSourceObjectRttiClass.GetProperty(LTargetRttiProperty.Name);
    try
      if LSourceRttiProperty <> nil then
        LTargetRttiProperty.SetValue(
          ATargetObjectWithSameCaseInsensitivePropertyName,
          LSourceRttiProperty.GetValue(ASourceObjectWithSameCaseInsensitivePropertyName)
        );
    except
      on E: Exception do
      begin
        E.Message := E.Message
          + #13#10 + 'Cannot assign '
          + '<' + ASourceObjectWithSameCaseInsensitivePropertyName.ClassName + '>.'
            + LSourceRttiProperty.Name + ' (' + LSourceRttiProperty.PropertyType.Name + ')'
          + ' to <' + ATargetObjectWithSameCaseInsensitivePropertyName.ClassName + '>.'
            + LTargetRttiProperty.Name + ' (' + LTargetRttiProperty.PropertyType.Name + ').';
        raise;
      end;
    end;
  end;
end;

procedure TPropertyValueTransferrer.TransferValuesBasedOnPropertyNameMapping(
  const APropertyNameMapping: IList<Tuple<string, string>>;
  const ASourceObject: TObject;
  const ATargetObject: TObject
);
const
  CThisProcess = 'property-name-mapping-based value transferrer';
var
  LRttiContextRecord: TRttiContext;
  LSourceObjectRttiClass: TRttiType;
  LTargetObjectRttiClass: TRttiType;
  LPropertyNamePair: Tuple<string, string>;
  LTargetRttiProperty: TRttiProperty;
  LSourceRttiProperty: TRttiProperty;
begin
  if not Assigned(APropertyNameMapping) then
    raise Exception.Create('The ' + CThisProcess + ' is missing the mapping.');
  if not Assigned(ASourceObject) then
    raise Exception.Create('The ' + CThisProcess + ' is missing the source object.');
  if not Assigned(ATargetObject) then
    raise Exception.Create('The ' + CThisProcess + ' is missing the target object.');

  LSourceObjectRttiClass := LRttiContextRecord.GetType(ASourceObject.ClassType);
  LTargetObjectRttiClass := LRttiContextRecord.GetType(ATargetObject.ClassType);

  for LPropertyNamePair in APropertyNameMapping do
  begin
    LSourceRttiProperty := LSourceObjectRttiClass.GetProperty(LPropertyNamePair.Value1);
    LTargetRttiProperty :=  LTargetObjectRttiClass.GetProperty(LPropertyNamePair.Value2);

    if (LSourceRttiProperty = nil) or (LTargetRttiProperty = nil) then
      Continue;

    try
      LTargetRttiProperty.SetValue(ATargetObject, LSourceRttiProperty.GetValue(ASourceObject));
    except
      on E: Exception do
      begin
        E.Message := E.Message
          + #13#10 + 'Cannot assign '
          + '<' + ASourceObject.ClassName + '>.' + LSourceRttiProperty.Name
          + ' (' + LSourceRttiProperty.PropertyType.Name + ')'
          + ' to <' + ATargetObject.ClassName + '>.' + LTargetRttiProperty.Name
          + ' (' + LTargetRttiProperty.PropertyType.Name + ').';
        raise;
      end;
    end;
  end;
end;

end.
