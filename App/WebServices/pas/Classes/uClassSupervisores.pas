{
 WEB SERVICES Vers�o 2022.11.0001
+--------------------------------------------------------------------------------------------------------------------------+
 Objeto referente as informa��es dos clientes, ir� realizar os select, insert e update
 Data Cria��o........: 12/12/2022
 Autor...............: Hilson Santos
+--------------------------------------------------------------------------------------------------------------------------+
}
unit uClassSupervisores;

interface

uses
    System.SysUtils,
    Data.DB,
    Data.Win.ADODB,
    uDWConsts;

type
    TSupervisores = class
      private
          FSupervisorId: string;
          FRcaId:        string;
          FGerenteId:    string;
          FNome:         string;
          FStatus:       string;
      public
          QOracleConsinco,
          QOracleMaxima: TADOQuery;
          QInsertInto: string;
          property SupervisorId: string read FSupervisorId write FSupervisorId;
          property RcaId:        string read FRcaId        write FRcaId;
          property GerenteId:    string read FGerenteId    write FGerenteId;
          property Nome:         string read FNome         write FNome;
          property Status:       string read FStatus       write FStatus;
          function ListarSupervisores(out Erro: string): TADOQuery;
          function CheckSupervisor(CodSupervisor: string; out TRequest: TRequestType): TRequestType;
          function InsertSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao: string; out Erro: string): TADOQuery;
          function UpdateSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao: string; out Erro: string): TADOQuery;
    end;

implementation

{ TSupervisores }

uses uDmBaseDados;

{ LISTA OS SUPERVISORES }
{ Essa fun��o lista os supervisores no banco de dados do ERP CONCINCO da tabela "MAD_REPRESENTANTE join MAD_EQUIPE" }
function TSupervisores.ListarSupervisores(out Erro: string): TADOQuery;
begin
    QOracleConsinco:= TADOQuery.Create(nil); // Est�ncia o objeto "QOracleConsinco"
    with fDmBaseDados do begin
         try
            with QOracleConsinco do begin
                 Connection:= connConcinco;
                 Close;
                 with SQL do begin
                      Clear;
                      Add(
                          'SELECT ' +
                          '      a.nrorepresentante seqsupervisor,' +
                          '      a.seqpessoa seqrca,' +
                          '      NVL(d.seqpessoa, 0) seqgerente,' +
                          '      b.nomerazao nome,' +
                          '      a.status status,' +
                          '      NVL(to_char(a.dtaalteracao,''dd/mm/yyyy''),''01/01/1994'') dtaalteracao ' +
                          'FROM implantacao.mad_representante a ' +
                          'INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa ' +
                          'INNER JOIN implantacao.mad_equipe c ON c.nroequipe = a.nroequipe ' +
                          'LEFT  JOIN implantacao.mad_equipe d ON d.nroequipe = c.nroequipesuperior ' +
                          'WHERE 1=1 ' +
                          'AND a.seqpessoa not in (1,22401) ' +
                          'AND a.tiprepresentante = ''S'''
                      );
                 end;
                 Prepared:= True;
                 Open;
                 Erro:= '';
                 Result:= QOracleConsinco;
            end;
            except on E: Exception do begin
                 Erro:= 'Erro ao listar supervisores: ' + E.Message;
                 Result:= nil;
                 QOracleConsinco.DisposeOf; // Destroi o objeto da mem�ria
            end;
         end;
    end;
end;

{ CHECA O SUPERVISOR }
{ Essa fun��o verificar se j� existe o supervisor na tabela "MXSSUPERV" na aplica��o da MAXIMA }
function TSupervisores.CheckSupervisor(CodSupervisor: string; out TRequest: TRequestType): TRequestType;
begin
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objeto QOracleMaxima
    with fDmBaseDados do begin
         try
             with QOracleMaxima do begin
                  Connection:= connMaxima;
                  Close;
                  with SQL do begin
                       Clear;
                       Add(
                           'SELECT * ' +
                           'FROM mxssuperv ' +
                           'WHERE 1=1 ' +
                           'AND codsupervisor = :CodSupervisor'
                       );
                       Parameters.ParamByName('CodSupervisor').Value:= CodSupervisor;
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
                 QOracleMaxima.DisposeOf; // Destroi o componente da mem�ria
         end;
    end;
end;

{ INSERIR OS SUPERVISORES }
{ Essa fun��o realiza o insert na tabela "MXSSUPERV" da aplica��o MAXIMA }
function TSupervisores.InsertSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao: string; out Erro: string): TADOQuery;
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
                      Erro:= 'Erro ao inserir o supervisor: ' + E.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

{ ALTERA OS SUPERVISORES }
{ Essa fun��o realiza update na tabela "MXSSUPERV" da aplica��o MAXIMA }
function TSupervisores.UpdateSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao: string; out Erro: string): TADOQuery;
begin
    with fDmBaseDados do begin
         with connMaxima do begin
              BeginTrans; // Inicia uma transa��o
              try
                  QOracleMaxima:= TADOQuery.Create(nil);
                  with QOracleMaxima do begin
                       Connection:= connMaxima;
                       Close;
                       with SQL do begin
                            Clear;
                            Add(
                                'UPDATE mxssuperv ' +
                                'SET cod_cadrca = :CodRca, codgerente = :CodGerente, nome = :NoSupervisor, posicao = :CodSituacao ' +
                                'WHERE 1=1 ' +
                                'AND codsupervisor = :CodSupervisor'
                            );
                            with Parameters do begin
                                 ParamByName('CodSupervisor').Value:= CoSupervisor;
                                 ParamByName('CodRca').Value:= CoRca;
                                 ParamByName('CodGerente').Value:= CoGerente;
                                 ParamByName('NoSupervisor').Value:= NoSupervisor;
                                 ParamByName('CodSituacao').Value:= CoSituacao;
                            end;
                       end;
                       Prepared:= True;
                       ExecSQL;
                  end;
                  CommitTrans; // Finaliza uma transa��o
                  Erro:= '';
                  Result:= QOracleMaxima;
                  QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  except on Ex: Exception do begin
                      RollbackTrans; // Desfaz uma transa��o
                      Erro:= 'Erro ao alterar o supervisor: ' + Ex.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

end.
