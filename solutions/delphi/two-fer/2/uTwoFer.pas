unit utwofer;

interface
  function twoFer(const AName: string = 'you'): string;

implementation

  function twoFer(const AName: string = 'you'): string;
  begin
      Result := 'One for ' + AName + ', one for me.'
  end;

end.