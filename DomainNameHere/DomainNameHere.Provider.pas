unit DomainNameHere.Provider;

interface

uses
  DomainNameHere.DataObject
  , DomainNameHere.Helper
  , Spring.Collections
  , Spring
  ;

type
  IMainDataObjectProvider = interface
    ['{97D72BC1-C712-4D86-8E7E-FE7708DC0978}']
    procedure TransferValues(
      const ASourceMainDataObjectWithSameCaseInsensitivePropertyName: TObject;
      const AMainDataObject: TMainDataObject
    ); overload;
    procedure TransferValues(
      const APropertyNameMapping: IList<Tuple<string, string>>;
      const ASourceMainDataObject: TObject;
      const AMainDataObject: TMainDataObject
    ); overload;
  end;

  TMainDataObjectProvider = class(TInterfacedObject, IMainDataObjectProvider)
  private
    FPropertyValueTransferrer: IPropertyValueTransferrer;
  public
    constructor Create(const AConverter: IPropertyValueTransferrer);
    procedure TransferValues(
      const ASourceMainDataObjectWithSameCaseInsensitivePropertyName: TObject;
      const AMainDataObject: TMainDataObject
    ); overload;
    procedure TransferValues(
      const APropertyNameMapping: IList<Tuple<string, string>>;
      const ASourceMainDataObject: TObject;
      const AMainDataObject: TMainDataObject
    ); overload;
  end;

implementation

uses
  System.SysUtils
  , System.Rtti
  ;

{ TMainDataObjectProvider }

constructor TMainDataObjectProvider.Create(const AConverter: IPropertyValueTransferrer);
begin
  FPropertyValueTransferrer := AConverter;
end;

procedure TMainDataObjectProvider.TransferValues(
  const ASourceMainDataObjectWithSameCaseInsensitivePropertyName: TObject;
  const AMainDataObject: TMainDataObject
);
begin
  if FPropertyValueTransferrer = nil then
    raise Exception.Create('Please create this provider using an object converter.');

  FPropertyValueTransferrer.TransferValuesBasedOnSameCaseInsensitivePropertyName(
    ASourceMainDataObjectWithSameCaseInsensitivePropertyName,
    AMainDataObject
  );
end;

procedure TMainDataObjectProvider.TransferValues(
  const APropertyNameMapping: IList<Tuple<string, string>>;
  const ASourceMainDataObject: TObject;
  const AMainDataObject: TMainDataObject
);
begin
  if FPropertyValueTransferrer = nil then
    raise Exception.Create('Please create this provider using an object converter.');

  FPropertyValueTransferrer.TransferValuesBasedOnPropertyNameMapping(
    APropertyNameMapping,
    ASourceMainDataObject,
    AMainDataObject
  );
end;

end.

