{
 WEB SERVICES Vers�o 2022.11.0001
+--------------------------------------------------------------------------------------------------------------------------+
 Objeto referente as informa��es das pra�as, ir� realizar os select, insert e update
 Data Cria��o........: 07/12/2022
 Autor...............: Hilson Santos
+--------------------------------------------------------------------------------------------------------------------------+
}
unit uClassPracas;

interface

uses
    System.SysUtils,
    Data.DB,
    Data.Win.ADODB,
    uDWConsts;

type
    TPracas = class
    private
        FPracaId:     string;
        FRegiaoId:    string;
        FRotaId:      string;
        FPracaNome:   string;
        FPracaStatus: string;
    public
        QOracleConsinco,
        QOracleMaxima:    TADOQuery;
        QInsertInto: string;
        property PracaId:     string read FPracaId      write FPracaId;
        property RegiaoId:    string read FRegiaoId     write FRegiaoId;
        property RotaId:      string read FRotaId       write FRotaId;
        property PracaNome:   string read FPracaNome    write FPracaNome;
        property PracaStatus: string read FPracaStatus  write FPracaStatus;
        function ListarPracas(out Erro: string): TADOQuery;
        function CheckPraca(CodPraca: string; out TRequest: TRequestType): TRequestType;
        function InsertPracas(CoPraca, CoRegiao, CoRota, NoPraca, CoSituacao: string; out Erro: string): TADOQuery;
        function UpdatePracas(CoPraca, CoRegiao, CoRota, NoPraca, CoSituacao: string; out Erro: string): TADOQuery;
    end;

implementation

uses  uDmBaseDados;

{ TPracas }

{ LISTA AS PRACAS }
{ Essa fun��o lista as pra�as no banco de dados do ERP CONCINCO da tabela "MAD_PRACA" }
function TPracas.ListarPracas(out Erro: string): TADOQuery;
begin
    QOracleConsinco:= TADOQuery.Create(nil); // Est�ncia o objeto "TQueryConsinco"
    with fDmBaseDados do begin
         try
             with QOracleConsinco do begin
                  Connection:= connConcinco;
                  Close;
                  with SQL do begin
                       Clear;
                       Add(
                           'SELECT seqpraca,' +
                           '       seqrota,' +
                           '       descpraca,' +
                           '       0 nroregicao,' +
                           '       status ' +
                           'FROM implantacao.mad_praca ' +
                           'WHERE 1=1 ' +
                           'ORDER BY seqpraca ASC'
                       );
                  end;
                  Prepared:= True;
                  Open;
                  Erro:= '';
                  Result:= QOracleConsinco;
             end;
             except on E: Exception do begin
                 Erro:= 'Erro ao listar pra�as: ' + E.Message;
                 Result:= nil;
                 QOracleConsinco.DisposeOf; // Destroi o objeto da mem�ria
             end;
         end;
    end;
end;

{CHECAR A PRA�A }
{ Essa fun��o verificar se j� existe a cidade na tabela "MXSPRACA" na aplica��o da MAXIMA }
function TPracas.CheckPraca(CodPraca: string; out TRequest: TRequestType): TRequestType;
begin
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objeto "QOracleMaxima"
    with fDmBaseDados do begin
         try
             with QOracleMaxima do begin
                  Connection:= connMaxima;
                  Close;
                  with SQL do begin
                       Clear;
                       Add(
                           'SELECT * ' +
                           'FROM mxspraca ' +
                           'WHERE 1=1 ' +
                           'AND codpraca = :CodPraca'
                       );
                       Parameters.ParamByName('CodPraca').Value:= CodPraca;
                  end;
                  Prepared:= True;
                  Open;

                  // Se a tabela estiver limpa, retorna o m�todo POST sen�o o PUT
                  if IsEmpty then
                     Result:= rtPost
                     else
                         Result:= rtPut;
             end;
             finally
                 QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
         end;
    end;
end;

{ INSERIR AS PRA�AS }
{ Essa fun��o realiza o insert na tabela "MXSPRACA" da aplica��o MAXIMA }
function TPracas.InsertPracas(CoPraca, CoRegiao, CoRota, NoPraca, CoSituacao: string; out Erro: string): TADOQuery;
begin
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objento "QOracleMaxima"
    with fDmBaseDados do begin
         with connMaxima do begin
              BeginTrans; // Inicia uma transa��o
              try
                  with QOracleMaxima do begin
                       Close;
                       Connection:= connMaxima;
                       with SQL do begin
                            Clear;
                            Add(
                                'INSERT ALL ' +
                                QInsertInto +
                                'SELECT * FROM DUAL'
                            );
                       end;
                       Prepared:= True;
                       ExecSQL;
                  end;
                  CommitTrans; // Finaliza uma transa��o
                  Erro:= '';
                  Result:= QOracleMaxima;
                  QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  except on E: Exception do begin
                      RollbackTrans; // Desfaz uma transa��o
                      Erro:= 'Erro ao inserir a pra�a: ' + E.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

{ ALTERA AS PRA�AS }
{ Essa fun��o realiza update na tabela "MXSPRACA" da aplica��o MAXIMA }
function TPracas.UpdatePracas(CoPraca, CoRegiao, CoRota, NoPraca, CoSituacao: string; out Erro: string): TADOQuery;
var
    Dados: string;
begin
    Dados:= CoPraca+CoRegiao+CoRota+NoPraca+CoSituacao;
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objeto "QOracleMaxima"
    with fDmBaseDados do begin
         with connMaxima do begin
              BeginTrans; // Inicia uma transa��o
              try
                  with QOracleMaxima do begin
                       Connection:= connMaxima;
                       Close;
                       with SQL do begin
                            Clear;
                            Add(
                                'SELECT *' +
                                'FROM implantacao.mad_praca ' +
                                'WHERE 1=1 ' +
                                'AND seqpraca||0||seqrota||descpraca||status = '''+Dados+''' ' +
                                'ORDER BY seqpraca ASC'
                            );
                       end;
                       Prepared:= True;
                       Open;
                       if IsEmpty then begin
                          First;
                          while not eof do begin
                                    with SQL do begin
                                         Clear;
                                         Add(
                                             'UPDATE mxspraca ' +
                                             'SET numregiao = :CodRegiao, rota = :CodRota, praca = :NomPraca, situacao = :CodSituacao ' +
                                             'WHERE 1=1 ' +
                                             'AND codpraca = :CodPraca'
                                         );
                                         with Parameters do begin
                                              ParamByName('CodPraca').Value:= CoPraca;
                                              ParamByName('CodRegiao').Value:= CoRegiao;
                                              ParamByName('CodRota').Value:= CoRota;
                                              ParamByName('NomPraca').Value:= NoPraca;
                                              ParamByName('CodSituacao').Value:= CoSituacao;
                                         end;
                                    end;
                                    Prepared:= True;
                                    ExecSQL;
                                    Next;
                          end;
                       end;
                  end;
                  CommitTrans;
                  Erro:= '';
                  Result:= QOracleMaxima;
                  QOracleMaxima.DisposeOf;
                  except on Ex: Exception do begin
                      RollbackTrans;
                      Erro:= 'Erro ao alterar a pra�a: ' + Ex.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf;
                  end;
              end;
         end;
    end;
end;

end.
