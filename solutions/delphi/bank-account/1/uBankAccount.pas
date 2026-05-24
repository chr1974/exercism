unit uBankAccount;

interface

uses
  System.SysUtils,
  System.SyncObjs;

type
  EAccountNotOpen = class(Exception)
  end;

  TBankAccountActiveStatus = (asOpen, asClosed);

  IBankAccount = interface
    ['{0D98220B-4D09-4F6D-8E90-F80FDA2CA4B3}']

    procedure SetBalance(const Value: Double);
    function GetBalance: Double;

    procedure Open;
    procedure Close;
    procedure UpdateBalance(AAmount: Double);

    property Balance: Double read GetBalance write SetBalance;
  end;

  TBankAccount = class(TInterfacedObject, IBankAccount)
    private
      FActiveStatus: TBankAccountActiveStatus;
      FBalance: Double;
      FLock: TCriticalSection;

      procedure SetBalance(const Value: Double);
      function GetBalance: Double;
    public
      constructor  Create;
      destructor Destroy; override;

      property Balance: Double read GetBalance write SetBalance;

      procedure Open;
      procedure Close;
      procedure UpdateBalance(AAmount: Double);
  end;

implementation

{ TBankAccount }

procedure TBankAccount.Close;
begin
  FLock.Enter;
  try
    FActiveStatus := asClosed;
  finally
    FLock.Leave;
  end;

end;

constructor TBankAccount.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TBankAccount.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TBankAccount.GetBalance: Double;
begin
  FLock.Enter;
  try
    If FActiveStatus = asClosed then
    raise EAccountNotOpen.Create('Error, Can`t get balance on a closed account');

    Result := FBalance;
  finally
    FLock.Leave;
  end;
end;

procedure TBankAccount.Open;
begin
  FLock.Enter;
  try
    FActiveStatus := asOpen;
  finally
    FLock.Leave;
  end;
end;

procedure TBankAccount.SetBalance(const Value: Double);
begin
  FLock.Enter;
  try
    FBalance := Value;
  finally
    FLock.Leave;
  end;
end;

procedure TBankAccount.UpdateBalance(AAmount: Double);
begin
  FLock.Enter;
  try
   if FActiveStatus = asClosed then
     raise EAccountNotOpen.Create('Update balance failed, Account is closed.')
   else
     FBalance := FBalance + AAmount;
  finally
    FLock.Leave;
  end;
end;

end.