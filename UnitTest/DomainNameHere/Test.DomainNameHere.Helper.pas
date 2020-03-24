unit Test.DomainNameHere.Helper;

interface

uses
  DUnitX.TestFramework
  , DUnitX.Assert
  , DomainNameHere.Helper
  , Data.DB
  ;

type
  TestTDataSetValueExtractor = class
  strict private const
    CTestDataSetStringFieldName = 'StringField';
    CTestDataSetStringFieldValue = 'abc';
    CTestDataSetIntegerFieldName = 'IntegerField';
    CTestDataSetIntegerFieldValue = 123;
    CTestDataSetDateFieldName = 'DateTimeField';
    CTestDataSetDateFieldValue: TDate = 1;
    CTestDataSetNonExistentFieldName = 'NonExistingField';
    CIsRaisingExceptionWhenFieldNotExist: Boolean = False;
  strict private
    FDataSetValueExtractor: IDataSetValueExtractor;
    FTestDataSet: TDataSet;
  public
    [SetUpFixture] procedure SetUp;
    [TearDownFixture] procedure TearDown;
    [Test] procedure TestGetDataSetField;
    [Test] procedure TestGetStringValueFromDataSet;
    [Test] procedure TestGetIntegerValueFromDataSet;
    [Test] procedure TestGetDateValueFromDataSet;
  end;

  TestTPropertyValueTransferrer = class
  strict private const
    CDummyStringValue = 'DUMMY';
    CDummyIntegerValue = -1;
  strict private
    FPropertyValueTransferrer: IPropertyValueTransferrer;
  public
    [SetupFixture] procedure SetUp;
    [Test] procedure TestTransferValuesBasedOnSameCaseInsensitivePropertyName;
    [Test] procedure TestTransferValuesBasedOnPropertyNameMapping;
  end;

  {$REGION 'Test Data Classes'}
  TTestSourceObject = class
  private
    FValue1: Variant;
    FValue2: Variant;
    FValue3: string;
    FValue4: Integer;
  public
    property SimilarPropertyName1CASEInsensitive: Variant read FValue1 write FValue1;
  published
    property SimilarPropertyName2RegardlessPublicOrPublished: Variant read FValue2 write FValue2;
    property SourceNonSimilarPropertyName1: string read FValue3 write FValue3;
    property SourceNonSimilarPropertyName2: Integer read FValue4 write FValue4;
  end;

  TTestTargetObject = class
  private
    FValue1: Variant;
    FValue2: Variant;
    FValue3: string;
    FValue4: Integer;
  public
    property SimilarPropertyName1CaseInsensitive: Variant read FValue1 write FValue1;
    property SimilarPropertyName2RegardlessPublicOrPublished: Variant read FValue2 write FValue2;
    property TargetNonSimilarPropertyName1: string read FValue3 write FValue3;
    property TargetNonSimilarPropertyName2: Integer read FValue4 write FValue4;
  end;
  {$ENDREGION }

  {$REGION 'Test Data Method'}
  function CreateTestDataSet(
    const AStringFieldName: string;
    const AIntegerFieldName: string;
    const ADateFieldName: string;
    const AExpectedStringValue: string;
    const AExpectedIntegerValue: Integer;
    const AExpectedDateValue: TDate
  ): TDataSet;
  {$ENDREGION}

implementation

uses
  Datasnap.DBClient
  , Spring.Collections
  , Spring
  , System.Variants
  ;

{$REGION 'Test Data Method'}
function CreateTestDataSet(
  const AStringFieldName: string;
  const AIntegerFieldName: string;
  const ADateFieldName: string;
  const AExpectedStringValue: string;
  const AExpectedIntegerValue: Integer;
  const AExpectedDateValue: TDate
): TDataSet;
begin
  Result := TClientDataSet.Create(nil);
  Result.FieldDefs.Add(AStringFieldName, ftString, 100);
  Result.FieldDefs.Add(AIntegerFieldName, ftInteger);
  Result.FieldDefs.Add(ADateFieldName, ftDateTime);
  TClientDataSet(Result).CreateDataSet;
  Result.AppendRecord([AExpectedStringValue, AExpectedIntegerValue, AExpectedDateValue]);
end;
{$ENDREGION}

{ TestTDataSetValueExtractor }

procedure TestTDataSetValueExtractor.SetUp;
begin
  FDataSetValueExtractor := TDataSetValueExtractor.Create;
  FTestDataSet := CreateTestDataSet(
    CTestDataSetStringFieldName,
    CTestDataSetIntegerFieldName,
    CTestDataSetDateFieldName,
    CTestDataSetStringFieldValue,
    CTestDataSetIntegerFieldValue,
    CTestDataSetDateFieldValue
  );
end;

procedure TestTDataSetValueExtractor.TearDown;
begin
  FTestDataSet.Free;
end;

procedure TestTDataSetValueExtractor.TestGetDataSetField;
begin
  Assert.AreEqual(
    CTestDataSetStringFieldName,
    FDataSetValueExtractor.GetDataSetField(
      FTestDataSet,
      CTestDataSetStringFieldName
    ).FieldName
  );

  Assert.WillRaise(
    procedure
    begin
      FDataSetValueExtractor.GetDataSetField(
        FTestDataSet,
        CTestDataSetNonExistentFieldName
      )
    end,
    EDatabaseError
  );

  Assert.IsNull(FDataSetValueExtractor.GetDataSetField(
    FTestDataSet,
    CTestDataSetNonExistentFieldName,
    CIsRaisingExceptionWhenFieldNotExist
  ));
end;

procedure TestTDataSetValueExtractor.TestGetStringValueFromDataSet;
const
  CDefaultValue = 'Default';
begin
  Assert.AreEqual(
    CTestDataSetStringFieldValue,
    FDataSetValueExtractor.GetStringValueFromDataSet(
      FTestDataSet,
      CTestDataSetStringFieldName
    )
  );

  Assert.AreEqual(
    CDefaultValue,
    FDataSetValueExtractor.GetStringValueFromDataSet(
      FTestDataSet,
      CTestDataSetNonExistentFieldName,
      CIsRaisingExceptionWhenFieldNotExist,
      CDefaultValue
    )
  );
end;

procedure TestTDataSetValueExtractor.TestGetIntegerValueFromDataSet;
const
  CDefaultValue = 321;
begin
  Assert.AreEqual(
    CTestDataSetIntegerFieldValue,
    FDataSetValueExtractor.GetIntegerValueFromDataSet(
      FTestDataSet,
      CTestDataSetIntegerFieldName
    )
  );

  Assert.AreEqual(
    CDefaultValue,
    FDataSetValueExtractor.GetIntegerValueFromDataSet(
      FTestDataSet,
      CTestDataSetNonExistentFieldName,
      CIsRaisingExceptionWhenFieldNotExist,
      CDefaultValue
    )
  );
end;

procedure TestTDataSetValueExtractor.TestGetDateValueFromDataSet;
const
  CDefaultValue: TDate = 0;
begin
  Assert.AreEqual(
    CTestDataSetDateFieldValue,
    FDataSetValueExtractor.GetDateValueFromDataSet(
      FTestDataSet,
      CTestDataSetDateFieldName
    )
  );

  Assert.AreEqual(
    CDefaultValue,
    FDataSetValueExtractor.GetDateValueFromDataSet(
      FTestDataSet,
      CTestDataSetNonExistentFieldName,
      CIsRaisingExceptionWhenFieldNotExist,
      CDefaultValue
    )
  );
end;

{ TestTPropertyValueTransferrer }

procedure TestTPropertyValueTransferrer.SetUp;
begin
  FPropertyValueTransferrer := TPropertyValueTransferrer.Create;
end;

procedure TestTPropertyValueTransferrer.TestTransferValuesBasedOnSameCaseInsensitivePropertyName;
var
  LExpectedValueOfSimilarPropertyName1: Variant;
  LExpectedValueOfSimilarPropertyName2: Variant;
  LExpectedDefaultValueOfTargetNonSimilarPropertyName1: string;
  LExpectedDefaultValueOfTargetNonSimilarPropertyName2: Integer;
  LTestSourceObject: TTestSourceObject;
  LTestTargetObject: TTestTargetObject;
begin
  LExpectedValueOfSimilarPropertyName1 := 'abc';
  LExpectedValueOfSimilarPropertyName2 := 123;
  LExpectedDefaultValueOfTargetNonSimilarPropertyName1 := '';
  LExpectedDefaultValueOfTargetNonSimilarPropertyName2 := 0;

  LTestSourceObject := TTestSourceObject.Create;
  LTestTargetObject := TTestTargetObject.Create;
  try
    LTestSourceObject.SimilarPropertyName1CASEInsensitive :=
      LExpectedValueOfSimilarPropertyName1;
    LTestSourceObject.SimilarPropertyName2RegardlessPublicOrPublished :=
      LExpectedValueOfSimilarPropertyName2;
    LTestSourceObject.SourceNonSimilarPropertyName1 := CDummyStringValue;
    LTestSourceObject.SourceNonSimilarPropertyName2 := CDummyIntegerValue;

    FPropertyValueTransferrer.TransferValuesBasedOnSameCaseInsensitivePropertyName(
      LTestSourceObject,
      LTestTargetObject
    );
    Assert.AreEqual(
      LExpectedValueOfSimilarPropertyName1,
      LTestTargetObject.SimilarPropertyName1CaseInsensitive
    );
    Assert.AreEqual(
      LExpectedValueOfSimilarPropertyName2,
      LTestTargetObject.SimilarPropertyName2RegardlessPublicOrPublished
    );
    Assert.AreEqual(
      LExpectedDefaultValueOfTargetNonSimilarPropertyName1,
      LTestTargetObject.TargetNonSimilarPropertyName1
    );
    Assert.AreEqual(
      LExpectedDefaultValueOfTargetNonSimilarPropertyName2,
      LTestTargetObject.TargetNonSimilarPropertyName2
    );

  finally
    LTestTargetObject.Free;
    LTestSourceObject.Free;
  end;
end;

procedure TestTPropertyValueTransferrer.TestTransferValuesBasedOnPropertyNameMapping;
var
  LExpectedValueOfMappedPropertyName1: string;
  LExpectedValueOfMappedPropertyName2: Integer;
  LTestSourceObject: TTestSourceObject;
  LTestTargetObject: TTestTargetObject;
  LPropertyNameMap: IList<Tuple<string, string>>;
begin
  LExpectedValueOfMappedPropertyName1 := 'abc';
  LExpectedValueOfMappedPropertyName2 := 123;

  LTestSourceObject := TTestSourceObject.Create;
  LTestTargetObject := TTestTargetObject.Create;
  try
    LTestSourceObject.SourceNonSimilarPropertyName1 :=
      LExpectedValueOfMappedPropertyName1;
    LTestSourceObject.SourceNonSimilarPropertyName2 :=
      LExpectedValueOfMappedPropertyName2;
    LTestSourceObject.SimilarPropertyName1CASEInsensitive := CDummyStringValue;
    LTestSourceObject.SimilarPropertyName2RegardlessPublicOrPublished := CDummyIntegerValue;

    LPropertyNameMap := TCollections.CreateList<Tuple<string, string>>;
    LPropertyNameMap.Add(
      Tuple<string, string>.Create('SourceNonSimilarPropertyName1', 'TargetNonSimilarPropertyName1')
    );
    LPropertyNameMap.Add(
      Tuple<string, string>.Create('SourceNonSimilarPropertyName2', 'TargetNonSimilarPropertyName2')
    );

    FPropertyValueTransferrer.TransferValuesBasedOnPropertyNameMapping(
      LPropertyNameMap,
      LTestSourceObject,
      LTestTargetObject
    );
    Assert.AreEqual(
      LExpectedValueOfMappedPropertyName1,
      LTestTargetObject.TargetNonSimilarPropertyName1
    );
    Assert.AreEqual(
      LExpectedValueOfMappedPropertyName2,
      LTestTargetObject.TargetNonSimilarPropertyName2
    );
    Assert.AreEqual(
      System.Variants.Unassigned,
      LTestTargetObject.SimilarPropertyName1CaseInsensitive
    );
    Assert.AreEqual(
      System.Variants.Unassigned,
      LTestTargetObject.SimilarPropertyName2RegardlessPublicOrPublished
    );

  finally
    LTestTargetObject.Free;
    LTestSourceObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestTDataSetValueExtractor);
  TDUnitX.RegisterTestFixture(TestTPropertyValueTransferrer);
end.

