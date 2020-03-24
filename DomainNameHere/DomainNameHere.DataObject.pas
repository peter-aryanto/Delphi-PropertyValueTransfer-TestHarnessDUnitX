unit DomainNameHere.DataObject;

interface

type
  TChildDataObject = class
    FRandomlyNamedVariantField: Variant;
    property RandomlyNamedVariantField: Variant
      read FRandomlyNamedVariantField write FRandomlyNamedVariantField;
  end;

  TMainDataObject = class
  private
    FStringField: string;
    FIntegerField: Integer;
    FBooleanField: Boolean;
    FDateTimeField: TDateTime;
    FVariantField: Variant;
    FChildDataObjectField: TChildDataObject;
    FAnotherStringField: string;
  public
    property PropertyOfStringField: string read FStringField write FStringField;
    property PropertyOfIntegerField: Integer read FIntegerField write FIntegerField;
    property PropertyOfBooleanField: Boolean read FBooleanField write FBooleanField;
    property PropertyOfDateTimeField: TDateTime read FDateTimeField write FDateTimeField;
    property PropertyOfVariantField: Variant read FVariantField write FVariantField;
    property PropertyOfObjectField: TChildDataObject
      read FChildDataObjectField write FChildDataObjectField;
    property PropertyOfAnotherStringField: string
      read FAnotherStringField write FAnotherStringField;
  end;

implementation

end.
