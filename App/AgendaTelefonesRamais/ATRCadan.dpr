program ATRCadan;

uses
  Vcl.Forms,
  Principal in 'pas\Principal.pas' {fPrincipal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
