{
 WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Sistema de integra��o do aplicativo da Maxima com ERP Concinco
 Data Inicio.........: 03/11/2022
 Data Previs�o.......: 30/06/2023
 Data Final..........:
 Data Cria��o........: 03/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+
}
program WSCadan;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uPrincipal in 'pas\uPrincipal.pas' {fPrincipal},
  uSobre in 'pas\uSobre.pas' {fSobre},
  uSplash in 'pas\uSplash.pas' {fSplash},
  uParametrizacao in 'pas\uParametrizacao.pas' {fParametrizacao},
  uParametrizacaoEdit in 'pas\uParametrizacaoEdit.pas' {fParametrizacaoEdit};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar:= True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
