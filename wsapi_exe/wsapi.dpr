program wsapi;

uses
  Vcl.Forms,
  main in 'main.pas' {principal},
  QR in 'util\QR.pas',
  winSocket in 'util\winSocket.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tprincipal, principal);
  Application.Run;
end.
