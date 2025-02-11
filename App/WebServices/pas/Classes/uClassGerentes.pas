{
 WEB SERVICES Vers�o 2022.11.0001
+--------------------------------------------------------------------------------------------------------------------------+
 Objeto referente as informa��es dos gerentes, ir� realizar os select, insert e update
 Data Cria��o........: 13/12/20222
 Autor...............: Hilson Santos
+--------------------------------------------------------------------------------------------------------------------------+
}
unit uClassGerentes;

interface

uses
    System.SysUtils,
    Data.DB,
    Data.Win.ADODB,
    uDWConsts;
type
    TGerentes = class
      private
          FGerenteId: string;
          FRcaId:     string;
          FNome:      string;
      public
          QOracleConsinco,
          QOracleMaxima: TADOQuery;
          QInsertInto: string;
          property GerenteId: string read FGerenteId write FGerenteId;
          property RcaId:     string read FRcaId     write FRcaId;
          property Nome:      string read FNome      write FNome;
          function ListarGerentes(out Erro: string): TADOQuery;
          function CheckGerente(CodGerente: string; out TRequest: TRequestType): TRequestType;
          function InsertGerentes(CoGerente, CoRca, NoGerente: string; out Erro: string): TADOQuery;
          function UpdateGerentes(CoGerente, CoRca, NoGerente: string; out Erro: string): TADOQuery;
      end;

implementation

{ TGerentes }

uses uDmBaseDados;

{ LISTA DOS GERENTES }
{ Essa fun��o lista os gerentes no banco de dados do ERP CONCINCO da tabela "MAD_REPRESENTANTE join MAD_EQUIPE" }
function TGerentes.ListarGerentes(out Erro: string): TADOQuery;
begin
    QOracleConsinco:= TADOQuery.Create(nil);  // Est�ncia o objeto "QOracleConsinco"
    with fDmBaseDados do begin
         try
            with QOracleConsinco do begin
                 Close;
                 Connection:= connConcinco;
                 with SQL do begin
                      Clear;
                      Add(
                          'SELECT ' +
                          '      a.nrorepresentante seqgerente,' +
                          '      a.seqpessoa seqrca,' +
                          '      d.nomerazao nome,' +
                          '      NVL(to_char(a.dtaalteracao,''dd/mm/yyyy''),''01/01/1994'') dtaalteracao ' +
                          'FROM implantacao.mad_representante a ' +
                          'INNER JOIN implantacao.mad_equipe b ON b.nroequipe = a.nroequipe ' +
                          'INNER JOIN implantacao.mad_equipe c ON c.nroequipe = b.nroequipesuperior ' +
                          'INNER JOIN implantacao.ge_pessoa d ON d.seqpessoa = c.seqpessoa ' +
                          'WHERE 1=1 ' +
                          'AND a.seqpessoa not in (1,22401) ' +
                          'AND a.tiprepresentante = ''G'''
                      );
                 end;
                 Prepared:= True;
                 Erro:= '';
                 Result:= QOracleConsinco;
            end;
            except on E: Exception do begin
                 Erro:= 'Erro ao listar gerentes: ' + E.Message;
                 Result:= nil;
            end;
         end;
    end;
end;

{ CHECA O GERENTE }
{ Essa fun��o verificar se j� existe o gerente na tabela "MXSGERENTE" na aplica��o da MAXIMA }
function TGerentes.CheckGerente(CodGerente: string; out TRequest: TRequestType): TRequestType;
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
                           'FROM mxsgerente ' +
                           'WHERE 1=1 ' +
                           'AND codgerente = :CodGerente'
                       );
                       Parameters.ParamByName('CodGerente').Value:= CodGerente;
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

{ INSERIR OS GERENTES }
{ Essa fun��o realiza o insert na tabela "MXSGERENTE" da aplica��o MAXIMA }
function TGerentes.InsertGerentes(CoGerente, CoRca, NoGerente: string; out Erro: string): TADOQuery;
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
                      Erro:= 'Erro ao inserir o gerente: ' + E.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

{ ALTERA OS GERENTES }
{ Essa fun��o realiza update na tabela "MXSGERENTE" da aplica��o MAXIMA }
function TGerentes.UpdateGerentes(CoGerente, CoRca, NoGerente: string; out Erro: string): TADOQuery;
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
                                'UPDATE mxsgerente ' +
                                'SET cod_cadrca = :CodRca, nomegerente = :NomGerente ' +
                                'WHERE 1=1 ' +
                                'AND codgerente = :CodGerente'
                            );
                            with Parameters do begin
                                 ParamByName('CodGerente').Value:= CoGerente;
                                 ParamByName('CodRca').Value:= CoRca;
                                 ParamByName('NomGerente').Value:= NoGerente;
                            end;
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
                      Erro:= 'Erro ao alterar o gerente: ' + E.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

end.
