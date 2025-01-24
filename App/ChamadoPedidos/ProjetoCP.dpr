program ProjetoCP;

uses
  Vcl.Forms,
  ConexaoQuery in 'pas\ConexaoQuery.pas' {DM: TDataModule},
  TelaPedidos in 'pas\TelaPedidos.pas' {frmTelaPedidos},
  TelaPesquisa in 'pas\TelaPesquisa.pas' {frmTelaPesquisa},
  TelaPrincipal in 'pas\TelaPrincipal.pas' {frmPrincipal},
  UnitChamadaFinal in 'pas\UnitChamadaFinal.pas' {frmChamadaFinal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
