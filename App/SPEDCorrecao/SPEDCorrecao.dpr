{
SPED-CORREÇÃO Versão 2022.11.1.23
+---------------------------------------------------------------------------+
 Sistema de correção dos SPED gerado pelo sistema CONSINCO
 Data Inicio.........: 23/11/2022
 Data Previsão.......: 06/12/2022
 Data Final..........: 01/12/2022
 Data Criação........: 23/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+
}
program SPEDCorrecao;

uses
  Vcl.Forms,
  uPrincipal in 'pas\uPrincipal.pas' {fPrincipal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
