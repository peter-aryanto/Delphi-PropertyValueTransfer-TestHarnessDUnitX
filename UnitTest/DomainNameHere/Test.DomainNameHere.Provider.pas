unit Test.DomainNameHere.Provider;

interface

uses
  DUnitX.TestFramework
  , DUnitX.Assert
  , DomainNameHere.DataObject
  ;

type
  TestTMainDataObjectProvider = class
  public
    [Test] procedure TestCreateFromDataSet;
    [Test] procedure TestTransferValues;
  end;

  {$REGION 'Test Data Classes'}
  TSourceObjectWithFieldsAndGetter_ForTesting = class
  public const
    CExpectdPrivateGetMethodMockResult = 'Hello private Get method.';
  private
    FStringField: string;
    FIntegerField: Integer;
    FBooleanField: Boolean;
    FDateTimeField: TDateTime;
    function PrivateGetMethodMock: Variant;
  public
    property PropertyOfVariantField: Variant read PrivateGetMethodMock;
  published
    property PropertyOfStringField: string read FStringField write FStringField;
    property PropertyOfIntegerField: Integer read FIntegerField write FIntegerField;
    property PropertyOfBooleanField: Boolean read FBooleanField write FBooleanField;
    property PropertyOfDateTimeField: TDateTime read FDateTimeField write FDateTimeField;
  end;

  TSourceObjectWithFields = class
  private
    FStringField: string;
    FChildDataObjectField: TChildDataObject;
  public
    property PropertyOfStringField: string read FStringField write FStringField;
    property PropertyOfObjectField: TChildDataObject
      read FChildDataObjectField write FChildDataObjectField;
  end;
  {$ENDREGION}

implementation

uses
  Data.DB
  , DomainNameHere.Helper
  , DomainNameHere.Provider
  , Test.DomainNameHere.Helper
  , System.SysUtils
  , Spring.Mocking
  , Spring.Collections
  , Spring
  ;

{ TestTMainDataObjectProvider }

procedure TestTMainDataObjectProvider.TestCreateFromDataSet;
const
  CExpectedStringValue = 'abc';
  CExpectedIntegerValue = 123;
  CExpectedDateValue : TDate = 1;
  CIsRaisingExceptionWhenFieldNotExist: Boolean = True;
var
  LDummyDataSet: TDataSet;
  LOptionalFieldNameList: IList<string>;
  LDataSetValueExtractorMock: Mock<IDataSetValueExtractor>;
//  LMainDataObjectProvider: IMainDataObjectProvider;
  LMainDataObject: TMainDataObject;
begin
  LDummyDataSet := Test.DomainNameHere.Helper.CreateTestDataSet(
    'DummyStringField',
    'DummyIntegerField',
    'DummyDateField',
    '',
    0,
    0
  );
  LMainDataObject := nil;
  try
    LOptionalFieldNameList := TCollections.CreateList<string>;
    LOptionalFieldNameList.Add('OptionalFieldName');

    LDataSetValueExtractorMock := Mock<IDataSetValueExtractor>.Create;
    LDataSetValueExtractorMock.Setup
      .Returns(CExpectedStringValue)
      .When.GetStringValueFromDataSet(
        Arg.IsAny<TDataSet>,
        Arg.IsNotIn<string>(LOptionalFieldNameList),
        Arg.IsEqual<Boolean>(CIsRaisingExceptionWhenFieldNotExist),
        Arg.IsAny<string>
      );
    LDataSetValueExtractorMock.Setup
      .Returns(CExpectedIntegerValue)
      .When.GetIntegerValueFromDataSet(
        Arg.IsAny<TDataSet>,
        Arg.IsAny<string>,
        Arg.IsEqual<Boolean>(CIsRaisingExceptionWhenFieldNotExist),
        Arg.IsAny<Integer>
      );
    LDataSetValueExtractorMock.Setup
      .Returns(CExpectedDateValue)
      .When.GetDateValueFromDataSet(
        Arg.IsAny<TDataSet>,
        Arg.IsAny<string>,
        Arg.IsEqual<Boolean>(CIsRaisingExceptionWhenFieldNotExist),
        Arg.IsAny<TDate>
      );

//    LMainDataObjectProvider := TMainDataObjectProvider.Create(LDataSetValueExtractorMock);
//    LMainDataObject := LMainDataObjectProvider.CreateFromDataSet(LDummyDataSet);

//    Assert.AreEqual(CExpectedStringValue, LMainDataObject.);
//    Assert.AreEqual(CExpectedIntegerValue, LMainDataObject.IhiNumberStatus);
//    Assert.AreEqual(CExpectedDateValue, LMainDataObject.);

  finally
    if Assigned(LMainDataObject) then LMainDataObject.Free;
    LDummyDataSet.Free;
  end;
end;

procedure TestTMainDataObjectProvider.TestTransferValues;
const
  CExpectedStringValue = 'Hello World';
  CExpectedIntegerValue = 123;
  CExpectedBooleanValue: Boolean = True;
  CExpectedDateTimeValue: TDateTime = 1;
  CNonSimilarPropertyDefaultStringValue = '';
var
  LTestSourceDataObject1: TSourceObjectWithFieldsAndGetter_ForTesting;
  LTestSourceDataObject2: TSourceObjectWithFields;
  LPropertyValueTransferrer: IPropertyValueTransferrer;
  LProvider: IMainDataObjectProvider;
  LTargetDataObject: TMainDataObject;
  LChildDataObject: TChildDataObject;
  LPropertyNameMapping: IList<Tuple<string, string>>;
begin
  LTestSourceDataObject1 := TSourceObjectWithFieldsAndGetter_ForTesting.Create;
  LTestSourceDataObject1.PropertyOfStringField := CExpectedStringValue;
  LTestSourceDataObject1.PropertyOfIntegerField := CExpectedIntegerValue;
  LTestSourceDataObject1.PropertyOfBooleanField := CExpectedBooleanValue;
  LTestSourceDataObject1.PropertyOfDateTimeField := CExpectedDateTimeValue;

  LTestSourceDataObject2 := TSourceObjectWithFields.Create;
  LTestSourceDataObject2.PropertyOfStringField := CExpectedStringValue;
  LChildDataObject := TChildDataObject.Create;
  LTestSourceDataObject2.PropertyOfObjectField := LChildDataObject;

  LPropertyValueTransferrer := TPropertyValueTransferrer.Create;
  LProvider := TMainDataObjectProvider.Create(LPropertyValueTransferrer);

  LTargetDataObject := TMainDataObject.Create;
  try
    LProvider.TransferValues(LTestSourceDataObject1, LTargetDataObject);
    // Verification for similar property names that refer to private fields.
    Assert.AreEqual(CExpectedStringValue, LTargetDataObject.PropertyOfStringField);
    Assert.AreEqual(CExpectedIntegerValue, LTargetDataObject.PropertyOfIntegerField);
    Assert.AreEqual(CExpectedBooleanValue, LTargetDataObject.PropertyOfBooleanField);
    Assert.AreEqual(CExpectedDateTimeValue, LTargetDataObject.PropertyOfDateTimeField);
    // Verification for similar property name that refers to a private (Get) method.
    Assert.AreEqual(
      Variant(TSourceObjectWithFieldsAndGetter_ForTesting.CExpectdPrivateGetMethodMockResult),
      LTargetDataObject.PropertyOfVariantField
    );
    // Verification for non similar property names.
    Assert.AreEqual(
      CNonSimilarPropertyDefaultStringValue,
      LTargetDataObject.PropertyOfAnotherStringField,
      'Non similar propery name should NOT have any value set (still having its default value).'
    );
    Assert.IsNull(LTargetDataObject.PropertyOfObjectField);

    // Verification for similar property name that refer to a private field holding an Object.
    LProvider.TransferValues(LTestSourceDataObject2, LTargetDataObject);
    Assert.AreEqual<TChildDataObject>(LChildDataObject, LTargetDataObject.PropertyOfObjectField);
    Assert.AreEqual(
      CExpectedStringValue,
      LTargetDataObject.PropertyOfStringField,
      'Previosly set value should remain set.'
    );
    Assert.AreEqual(
      CNonSimilarPropertyDefaultStringValue,
      LTargetDataObject.PropertyOfAnotherStringField,
      'Previously un-set value should remain un-set.'
    );

    // Verification for the usage of property name mapping.
    LPropertyNameMapping := TCollections.CreateList<Tuple<string, string>>;
    LPropertyNameMapping.Add(Tuple<string, string>.Create(
      'PropertyOfStringField',
      'PropertyOfAnotherStringField')
    );
    LProvider.TransferValues(
      LPropertyNameMapping,
      LTestSourceDataObject2,
      LTargetDataObject
    );
    Assert.AreEqual(CExpectedStringValue, LTargetDataObject.PropertyOfAnotherStringField);
    Assert.AreEqual(
      CExpectedStringValue,
      LTargetDataObject.PropertyOfStringField,
      'Previosly set value should remain set.'
    );

  finally
    LTargetDataObject.Free;
    LTestSourceDataObject2.Free;
    LChildDataObject.Free;
    LTestSourceDataObject1.Free;
  end;
end;

{$REGION 'Test Data Classes'}
{ TSourceObjectWithFieldsAndGetter_ForTesting }

function TSourceObjectWithFieldsAndGetter_ForTesting.PrivateGetMethodMock: Variant;
begin
  Result := CExpectdPrivateGetMethodMockResult;
end;
{$ENDREGION}

initialization
  TDUnitX.RegisterTestFixture(TestTMainDataObjectProvider);
  TDUnitX.RegisterTestFixture(TestTMainDataObjectProvider);
end.

