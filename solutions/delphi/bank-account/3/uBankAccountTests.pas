unit uBankAccountTests;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  BankAccountTests = class(TObject)
  public
    [Test]
    //[Ignore('Comment the "[Ignore]" statement to run the test')]
    procedure Returns_empty_balance_after_opening;

    [Test]
    //[Ignore]
    procedure Check_basic_balance;

    [Test]
    //[Ignore]
    procedure Balance_can_increment_and_decrement;

    [Test]
    //[Ignore]
    procedure Closed_account_throws_exception_when_checking_balance;

    [Test]
    //[Ignore]
    procedure Change_account_balance_from_multiple_threads;
  end;

implementation
uses System.SysUtils, System.Classes, System.SyncObjs, uBankAccount;

const HalfCentTolerance = 0.005;

procedure BankAccountTests.Returns_empty_balance_after_opening;
var account: IBankAccount;
begin
  account := TBankAccount.Create;
  account.Open;
  assert.AreEqual(0.00,account.Balance,HalfCentTolerance);
end;

procedure BankAccountTests.Check_basic_balance;
var account: IBankAccount;
    openingBalance: Double;
    updatedBalance: Double;
begin
  account := TBankAccount.Create;
  account.Open;

  openingBalance := account.Balance;
  account.UpdateBalance(10);

  updatedBalance := account.Balance;

  assert.AreEqual(0, openingBalance, HalfCentTolerance);
  assert.AreEqual(10, updatedBalance, HalfCentTolerance);
end;

procedure BankAccountTests.Balance_can_increment_and_decrement;
var account: IBankAccount;
    openingBalance: Double;
    addedBalance: Double;
    subtractedBalance: Double;
begin
  account := TBankAccount.Create;
  account.Open;

  openingBalance := account.Balance;

  account.UpdateBalance(10);
  addedBalance := account.Balance;

  account.UpdateBalance(-15);
  subtractedBalance := account.Balance;

  assert.AreEqual(0, openingBalance, HalfCentTolerance);
  assert.AreEqual(10, addedBalance, HalfCentTolerance);
  assert.AreEqual(-5, subtractedBalance, HalfCentTolerance);
end;

procedure BankAccountTests.Closed_account_throws_exception_when_checking_balance;
var MyProc: TTestLocalMethod;
begin
  MyProc := procedure
            var account: IBankAccount;
            begin
              account := TBankAccount.Create;
              account.Open;
              account.Close;
              account.Balance;
            end;

  assert.WillRaise(MyProc, EAccountNotOpen);
end;

procedure BankAccountTests.Change_account_balance_from_multiple_threads;
const threads = 500;
      iterations = 100;

var account: IBankAccount;
    activeThreadCount: integer;
    allthreadsDone: TEvent;
    i: integer;
begin
  activeThreadCount := threads;
  account := TBankAccount.Create;
  account.Open;

  allThreadsDone := TEvent.Create(nil, True, False,'AllThreadsDone');
  try
    allThreadsDone.ResetEvent;

    for i := 1 to threads do
    begin
      TThread.CreateAnonymousThread(
        procedure
        var j: integer;
        begin
          try
            for j := 1 to iterations do
            begin
              account.UpdateBalance(1);
              account.UpdateBalance(-1);
            end;
          finally
            //BUG in test:
          {* Plain dec(activeThreadCount) compiles to a read-modify-write
             sequence that is not atomic. With 500 threads, two threads routinely
             read the same value, both decrement it, and both write back — so the
             counter gets corrupted and often never reaches <= 0. The SetEvent
             call never fires → 60-second timeout. *}

            //dec(activeThreadCount); // Disabled dec(activeThreadCount);

            // using  TInterloced instead -- Test passed and no timeout.

            // TInterlocked.Decrement is an atomic fetch-and-decrement;
            // the return value IS the value after the decrement, so
            // exactly one thread will see 0 and signal the event.
            if TInterlocked.Decrement(activeThreadCount) = 0 then
              allthreadsDone.SetEvent;
          end;
        end)
        .Start;
    end;

    assert.AreEqual(wrSignaled,allthreadsDone.WaitFor(60000),
                    format('%d threads still active',[activeThreadCount]));
    assert.AreEqual(0, account.Balance, HalfCentTolerance);
  finally
    allThreadsDone.Free;
  end;



end;

initialization
  TDUnitX.RegisterTestFixture(BankAccountTests);
end.
