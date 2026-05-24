unit utwofer;

interface
  function twoFer(const AName: string = ''): string;

implementation

  function twoFer(const AName: string = ''): string;
  begin
    if AName <> '' then
      Result := 'One for ' + AName + ', one for me.'
    else
      Result := 'One for you, one for me.';
  end;

end.