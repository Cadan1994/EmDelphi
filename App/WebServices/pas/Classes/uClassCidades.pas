{
 WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Objeto referente as informa��es das cidades, ir� realizar os select, insert e update
 Data Cria��o........: 09/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+
}
unit uClassCidades;

interface

uses
    System.SysUtils,
    Data.DB,
    Data.Win.ADODB,
    FireDAC.Comp.Client,
    FireDAC.Stan.Param,
    uDWConsts;

type
    TCidades = class
    private
        //QPostgres:        TFDQuery;
        FCidadeId:   string;
        FCidadeIbge: string;
        FCidadeNome: string;
        FCidadeUf:   string;
    public
        QOracleConsinco,
        QOracleMaxima:    TADOQuery;
        QInsertInto: string;
        property CidadeId:   string read FCidadeId   write FCidadeId;
        property CidadeIbge: string read FCidadeIbge write FCidadeIbge;
        property CidadeNome: string read FCidadeNome write FCidadeNome;
        property CidadeUf:   string read FCidadeUf   write FCidadeUf;
        function ListarCidades(out Erro: string): TADOQuery;
        function CheckCidade(CodCidade: string; out TRequest: TRequestType): TRequestType;
        function InsertCidades(CoCidade, IbCidade, NoCidade, UfCidade: string; out Erro: string): TADOQuery;
        function UpdateCidades(CoCidade, IbCidade, NoCidade, UfCidade: string; out Erro: string): TADOQuery;
    end;

implementation

uses uDmBaseDados;

{ LISTA AS CIDADES }
{ Essa fun��o lista as cidades no banco de dados do ERP CONCINCO da tabela "GE_CIDADE" }
function TCidades.ListarCidades(out Erro: string): TADOQuery;
var
    QSql: string;
begin
    QOracleConsinco:= TADOQuery.Create(nil); // Est�ncia o objeto "QOracleConsinco"
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
                           'FROM mxscidade ' +
                           'WHERE 1=1'
                       );
                  end;
                  Prepared:= True;
                  Open;
                  if IsEmpty then begin
                     // Seleciona todas as cidades no banco de dados da CONSINCO
                     QSql:= 'SELECT seqcidade,' +
                            '       codibge,' +
                            '       regexp_replace(cidade, '''''''', '''') cidade,' +
                            '       uf,' +
                            '       NVL(to_char(dtaalteracao,''dd/mm/yyyy''),''01/01/1994'') dtaalteracao ' +
                            'FROM implantacao.ge_cidade ' +
                            'WHERE 1=1 ' +
                            'ORDER BY seqcidade ASC';
                  end else begin
                      // Seleciona todas as cidades no banco de dados da CONSINCO que foram atualizadas referente a D-1
                      QSql:= 'SELECT seqcidade,' +
                             '       codibge,' +
                             '       regexp_replace(cidade, '''''''', '''') cidade,' +
                             '       uf,' +
                             '       NVL(to_char(dtaalteracao,''dd/mm/yyyy''),''01/01/1994'') dtaalteracao ' +
                             'FROM implantacao.ge_cidade ' +
                             'WHERE 1=1 ' +
                             'AND dtaalteracao >= sysdate -1 ' +
                             'ORDER BY seqcidade ASC';
                  end;

                  with QOracleConsinco do begin
                       Connection:= connConcinco;
                       Close;
                       with SQL do begin
                            Clear;
                            Add(QSql);
                       end;
                       Prepared:= True;
                       Open;
                  end;
                  Erro:= '';
                  Result:= QOracleConsinco;
             end;
             except on E: Exception do begin
                 Erro:= 'Erro ao listar cidades: ' + E.Message;
                 Result:= nil;
                 QOracleConsinco.DisposeOf; // Destroi o objeto da mem�ria
                 QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
             end;
        end;
    end;
end;

{ CHECA A CIDADE }
{ Essa fun��o verificar se j� existe a cidade na tabela "MXSCIDADE" na aplica��o da MAXIMA }
function TCidades.CheckCidade(CodCidade: string; out TRequest: TRequestType): TRequestType;
begin
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objeto QOracleMaxima
    with fDmBaseDados do begin
         try
             with QOracleMaxima do begin
                  Connection:= connMaxima;
                  Close;
                  // Seleciona a cidade pelo c�digo
                  with SQL do begin
                       Clear;
                       Add(
                           'SELECT * ' +
                           'FROM mxscidade ' +
                           'WHERE 1=1 ' +
                           'AND codcidade = :CodCidade'
                       );
                       Parameters.ParamByName('CodCidade').Value:= CodCidade;
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

{ INSERIR AS CIDADES }
{ Essa fun��o realiza o insert na tabela "MXSCIDADE" da aplica��o MAXIMA }
function TCidades.InsertCidades(CoCidade, IbCidade, NoCidade, UfCidade: string; out Erro: string): TADOQuery;
begin
    QOracleMaxima:= TADOQuery.Create(nil); // Est�ncia o objento QOracleMaxima
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
                  except on Ex: Exception do begin
                      RollbackTrans; // Desfaz uma transa��o
                      Erro:= 'Erro ao inserir a cidade: ' + Ex.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf;  // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

{ ALTERA AS CIDADES }
{ Essa fun��o realiza update na tabela "MXSCIDADE" da aplica��o MAXIMA }
function TCidades.UpdateCidades(CoCidade, IbCidade, NoCidade, UfCidade: string; out Erro: string): TADOQuery;
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
                                'UPDATE mxscidade ' +
                                'SET codibge = :CodIbge, nomecidade = :NomeCidade, uf = :Uf ' +
                                'WHERE 1=1 ' +
                                'AND codcidade = :CodCidade'
                            );
                            with Parameters do begin
                                 ParamByName('CodCidade').Value:= CoCidade;
                                 ParamByName('CodIbge').Value:= IbCidade;
                                 ParamByName('NomeCidade').Value:= NoCidade;
                                 ParamByName('Uf').Value:= UfCidade;
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
                      Erro:= 'Erro ao alterar a cidade: ' + Ex.Message;
                      Result:= nil;
                      QOracleMaxima.DisposeOf; // Destroi o objeto da mem�ria
                  end;
              end;
         end;
    end;
end;

end.
