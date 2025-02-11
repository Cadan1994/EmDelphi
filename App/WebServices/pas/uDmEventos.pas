{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Reposit�rio dos eventos de requisi��es e respostas
 Data Cria��o........: 10/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uDmEventos;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.NetConsts,
  Vcl.Dialogs,
  Data.DB,
  Data.Win.ADODB,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  uDWDataModule,
  uDWAbout,
  uDWJSONObject,
  uDWConsts,
  uRESTDWServerContext,
  uRESTDWServerEvents,
  uRESTDWPoolerDB,
  REST.Types,
  REST.Client,
  REST.Authenticator.Basic,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient;

type
  TfDmEventos = class(TServerMethodDataModule)
    DWECidades: TDWServerEvents;
    DWEPracas: TDWServerEvents;
    DWESupervisores: TDWServerEvents;
    DWEGerentes: TDWServerEvents;
    procedure ServerMethodDataModuleCreate(Sender: TObject);
  private
    {
    TRequest: TRequestType;
    Query: TADOQuery;
    Json: uDWJSONObject.TJSONValue;
    Erro: string;
    JsonGetArray: TJSONArray;
    function ListarCidades(out StatusCode: Integer): string;
    function ListarPracas(out StatusCode: Integer): string;
    function ListarGerentes(out StatusCode: Integer): string;
    function ListarSupervisores(out StatusCode: Integer): string;
    }
    procedure DWServerEventsEventsAPICidades(
              var Params: TDWParams;
              var Result: string;
              const RequestType: TRequestType;
              var StatusCode: Integer; RequestHeader: TStringList);
    {
    procedure DWServerEventsEventsAPIPracas(
              var Params: TDWParams;
              var Result: string;
              const RequestType: TRequestType;
              var StatusCode: Integer; RequestHeader: TStringList);
    procedure DWServerEventsEventsAPIGerentes(
              var Params: TDWParams;
              var Result: string;
              const RequestType: TRequestType;
              var StatusCode: Integer; RequestHeader: TStringList);
    procedure DWServerEventsEventsAPISupervisores(
              var Params: TDWParams;
              var Result: string;
              const RequestType: TRequestType;
              var StatusCode: Integer; RequestHeader: TStringList);
    }
  public

  end;

var
  fDmEventos: TfDmEventos;
  Requisicao: string;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uDmBaseDados;

{$R *.dfm}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FUNCTIONS ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{ LISTAR CIDADES }
{ Essa fun��o executa a "ListarCidades" na classe "TCidades" }
{
function TfDmEventos.ListarCidades(out StatusCode: Integer): string;
var
    ClaCidade: TCidades;
begin
    ClaCidade:= TCidades.Create; // Est�ncia o objeto "ClaCidade"
    Json:= uDWJSONObject.TJSONValue.Create; // Est�ncia o objeto "Json"
    Query:= ClaCidade.ListarCidades(Erro); // O objeto recebe o resultado da query da fun��o "ListarCidades" na classe TCidades
    try
        try
            Json.LoadFromDataset('', Query, False, jmPureJSON, 'dd/mm/yyyy hh:nn'); // Executa os dados no dataset
            Result:= Json.ToJSON; // Recebe os dados no formato json
            StatusCode:= 200;
            except on E: Exception do begin
                //Result:= '["retorno": "' + E.Message + '"]';
                StatusCode:= 400;
            end;
        end;
        finally
            ClaCidade.DisposeOf;  // Destroy o objeto "ClaCidade"
            Json.DisposeOf;       // Destroy o objeto "Json"
            Query.DisposeOf;      // Destroy o objeto "Query"
    end;
end;
}
{ LISTAR PRA�AS }
{ Essa fun��o executa a "ListarPra�as" na classe "TPracas" }
{
function TfDmEventos.ListarPracas(out StatusCode: Integer): string;
var
    ClaPraca: TPracas;
begin
    ClaPraca:= TPracas.Create; // Est�ncia o objeto "ClaPraca"
    Json:= uDWJSONObject.TJSONValue.Create; // Est�ncia o objeto "Json"
    Query:= ClaPraca.ListarPracas(Erro); // O objeto recebe o resultado da query da fun��o "ListarPracas" na classe TPracas
    try
        try
            Json.LoadFromDataset('', Query, False, jmPureJSON, 'dd/mm/yyyy hh:nn'); // Executa os dados no dataset
            Result:= Json.ToJSON; // Recebe os dados no formato json
            StatusCode:= 200;
            except on E: Exception do begin
                Result:= '["retorno": "' + E.Message + '"]';
                StatusCode:= 400;
            end;
        end;
        finally
        ClaPraca.DisposeOf; // Destroy o objeto "ClaPraca"
        Json.DisposeOf;     // Destroy o objeto "Json"
        Query.DisposeOf;    // Destroy o objeto "Query"
    end;
end;
}
{ LISTAR GERENTES }
{ Essa fun��o executa a "ListarGerentes" na classe "TGerentes" }
{
function TfDmEventos.ListarGerentes(out StatusCode: Integer): string;
var
    ClaGerente: TGerentes;
begin
    ClaGerente:= TGerentes.Create; // Est�ncia o objeto "TGerente"
    Json:= uDWJSONObject.TJSONValue.Create; // Est�ncia o objeto "Json"
    Query:= ClaGerente.ListarGerentes(Erro); // O objeto recebe o resultado da query da fun��o "ListarGerentes" na classe TGerentes
    try
        try
            Json.LoadFromDataset('', Query, False, jmPureJSON, 'dd/mm/yyyy'); // Executa os dados no dataset
            Result:= Json.ToJSON; // Recebe os dados no formato json
            StatusCode:= 200;
            except on E: Exception do begin
                Result:= '["retorno": "' + E.Message + '"]';
                StatusCode:= 400;
            end;
        end;
        finally
        ClaGerente.DisposeOf; // Destroi o objeto "ClaGerente"
        Json.DisposeOf;       // Destroi o objeto "Json"
        Query.DisposeOf;      // Destroi o objeto "Query"
    end;
end;
}
{ LISTAR SUPERVISORES }
{ Essa fun��o executa a "ListarSupervisores" na classe "TSupervisores" }
{
function TfDmEventos.ListarSupervisores(out StatusCode: Integer): string;
var
    ClaSupervisor: TSupervisores;
begin
    ClaSupervisor:= TSupervisores.Create; // Est�ncia o objeto "ClaSupervisor"
    Json:= uDWJSONObject.TJSONValue.Create; // Est�ncia o objeto "Json"
    Query:= ClaSupervisor.ListarSupervisores(Erro); // O objeto recebe o resultado da query da fun��o "ListarSupervisores" na classe TSupervisores
    try
        try
            Json.LoadFromDataset('', Query, False, jmPureJSON, 'dd/mm/yyyy hh:nn'); // Executa os dados no dataset
            Result:= Json.ToJSON; // Recebe os dados no formato json
            StatusCode:= 200;
            except on E: Exception do begin
                Result:= '["retorno": "' + E.Message + '"]';
                StatusCode:= 400;
            end;
        end;
        finally
        ClaSupervisor.DisposeOf;  // Destroy o objeto "ClaSupervisor"
        Json.DisposeOf;           // Destroy o objeto "Json"
        Query.DisposeOf;          // Destroy o objeto "Query"
    end;
end;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PROCEDURES //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{ Essa procedure executa o evento "api-cadan/cidades" }
procedure TfDmEventos.DWServerEventsEventsAPICidades(
          var Params: TDWParams;
          var Result: string;
          const RequestType: TRequestType;
          var StatusCode: Integer; RequestHeader: TStringList);
var
    Http: THttpClient;
    HttpResponse: IHttpResponse;
begin
    Http:= THTTPClient.Create;
    try
        with Http do begin
             ContentType:= 'application/json';
             Accept:= 'application/json';
        end;
        HttpResponse:= Http.Get('http://127.0.0.1:8000/api/consinco/gerentes');
        Result:= HttpResponse.ContentAsString();
        finally
            Http.DisposeOf;
    end;
end;
{
 begin
    Http:= TIdHTTP.Create;
    try
       with Http do begin
            with Request do begin
                 Clear;
                 ContentType:= 'application/json';
                 Accept:= 'application/json';
                 sUrl:= 'http://127.0.0.1:8000/api/consinco/cidadestotal';
                 Method:= 'GET';
                 with Authentication do begin
                      Username:= 'meuusername';
                      Password:= 'meupassword';
                 end;
            end;
            sResponse:= Get(sUrl);
       end;
       finally

    end;
end;
}
{ Essa procedure executa o evento "api-cadan/pracas" }
{
procedure TfDmEventos.DWServerEventsEventsAPIPracas(
          var Params: TDWParams;
          var Result: string;
          const RequestType: TRequestType;
          var StatusCode: Integer; RequestHeader: TStringList);
var
    ClaPraca: TPracas;
    Codigo,
    Regiao,
    Rota,
    Nome,
    Situacao,
    JsonValue: string;
    I,
    TReg,
    QReg,
    LReg: Integer;
begin
    QReg:= 0;
    LReg:= LimiteRegistro;
    Result:= ListarPracas(StatusCode); // Recebe o resultado da fun��o "ListarPracas"
    if StatusCode = 200 then begin // Se o status code for 200, inseri os dados na tabela "MXSPRACA"
       JsonValue:= Result; // Recebe os dados no formato Json
       ClaPraca:= TPracas.Create; // Est�ncia o objeto ClaPraca
       try
           JsonGetArray:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonValue), 0) as TJSONArray; // Recebe o resultado do json
           if JsonGetArray.Count <> 0 then begin
              TReg:= JsonGetArray.Count;
              if TReg < LReg then
                 LReg:= TReg;
              with JsonGetArray do begin
                   for I:= 0 to Count - 1 do begin
                       QReg:= QReg + 1;
                       with Items[I] do begin
                            Codigo:=    GetValue<string> ('SEQPRACA');
                            Regiao:=    GetValue<string> ('NROREGICAO');
                            Rota:=      GetValue<string> ('SEQROTA');
                            Nome:=      GetValue<string> ('DESCPRACA');
                            Situacao:=  GetValue<string> ('STATUS');
                       end;

                       with ClaPraca do begin
                            TRequest:= CheckPraca(Codigo, TRequest);
                            if TRequest = TRequestType.rtPost then begin
                               QInsertInto:= QInsertInto +
                                             'INTO mxspraca(codpraca, numregiao, rota, praca, situacao)' +
                                             'VALUES' +
                                             '('''+Codigo+''', '''+Regiao+''', '''+Rota+''', '''+Nome+''', '''+Situacao+''')'
                                           ;

                               if QReg = LReg then begin
                                  InsertPracas(Codigo, Regiao, Rota, Nome, Situacao, Erro);
                                  TReg:= TReg - QReg;
                                  if TReg >= LReg then begin
                                     QReg:= 0;
                                     QInsertInto:= '';
                                  end;
                               end;

                               if TReg < LReg then begin
                                  LReg:= TReg;
                                  QReg:= 0;
                                  QInsertInto:= '';
                               end;

                            end else begin
                                UpdatePracas(Codigo, Regiao, Rota, Nome, Situacao, Erro);
                            end;
                       end;
                   end;
              end;
           end;
           finally
              ClaPraca.DisposeOf;
       end;
    end;
end;
}
{ Essa procedure executa o evento "api-cadan/gerentes" }
{
procedure TfDmEventos.DWServerEventsEventsAPIGerentes(
          var Params: TDWParams;
          var Result: string;
          const RequestType: TRequestType;
          var StatusCode: Integer; RequestHeader: TStringList);
var
    ClaGerente: TGerentes;
    Cogerente,
    CoRca,
    NoGerente,
    JsonValue: string;
    I,
    TReg,
    QReg,
    LReg: Integer;
begin
    QReg:= 0;
    LReg:= LimiteRegistro;
    Result:= ListarGerentes(StatusCode); // Recebe o resultado da fun��o "ListarGerentes"
    if StatusCode = 200 then begin // Se o status code for 200, inseri os dados na tabela "MXSGERENTE"
       JsonValue:= Result; // Recebe os dados no formato Json
       ClaGerente:= TGerentes.Create; // Est�ncia o objeto ClaGerente
       try
           JsonGetArray:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonValue), 0) as TJSONArray; // Recebe o resultado do json
           if JsonGetArray.Count <> 0 then begin
              TReg:= JsonGetArray.Count;
              if TReg < LReg then
                 LReg:= TReg;
              with JsonGetArray do begin
                   for I:= 0 to Count - 1 do begin
                       QReg:= QReg + 1;
                       with Items[I] do begin
                            Cogerente:= GetValue<string> ('SEQGERENTE');
                            CoRca:=     GetValue<string> ('SEQRCA');
                            NoGerente:= GetValue<string> ('NOME');
                       end;

                       with ClaGerente do begin
                            TRequest:= CheckGerente(Cogerente, TRequest);
                            if TRequest = TRequestType.rtPost then begin
                               QInsertInto:= QInsertInto +
                                             'INTO mxsgerente(codgerente, cod_cadrca, nomegerente)' +
                                             'VALUES' +
                                             '('''+Cogerente+''', '''+CoRca+''', '''+NoGerente+''')'
                                           ;

                               if QReg = LReg then begin
                                  InsertGerentes(Cogerente, CoRca, NoGerente, Erro);
                                  TReg:= TReg - QReg;
                                  if TReg >= LReg then begin
                                     QReg:= 0;
                                     QInsertInto:= '';
                                  end;
                               end;

                               if TReg < LReg then begin
                                  LReg:= TReg;
                                  QReg:= 0;
                                  QInsertInto:= '';
                               end;

                            end else begin
                                UpdateGerentes(Cogerente, CoRca, NoGerente, Erro);
                            end;
                       end;
                   end;
              end;
           end;
           finally
              ClaGerente.DisposeOf; // Destroi o objeto da mem�ria
       end;
    end;
end;
}
{ Essa procedure executa o evento "api-cadan/supervisores" }
{
procedure TfDmEventos.DWServerEventsEventsAPISupervisores(
          var Params: TDWParams;
          var Result: string;
          const RequestType: TRequestType;
          var StatusCode: Integer; RequestHeader: TStringList);
var
    ClaSupervisor: TSupervisores;
    CoSupervisor,
    CoRca,
    CoGerente,
    NoSupervisor,
    CoSituacao,
    JsonValue: string;
    I,
    TReg,
    QReg,
    LReg: Integer;
begin
    QReg:= 0;
    LReg:= LimiteRegistro;
    Result:= ListarSupervisores(StatusCode); // Recebe o resultado da fun��o "ListarSupervisores"
    if StatusCode = 200 then begin // Se o status code for 200, inseri os dados na tabela "MXSSUPERV"
       JsonValue:= Result; // Recebe os dados no formato Json
       ClaSupervisor:= TSupervisores.Create; // Est�ncia o objeto ClaSupervisor
       try
           JsonGetArray:= TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonValue), 0) as TJSONArray; // Recebe o resultado do json
           if JsonGetArray.Count <> 0 then begin
              TReg:= JsonGetArray.Count;
              if TReg < LReg then
                 LReg:= TReg;
              with JsonGetArray do begin
                   for I:= 0 to Count - 1 do begin
                       QReg:= QReg + 1;
                       with Items[I] do begin
                            CoSupervisor:= GetValue<string> ('SEQSUPERVISOR');
                            CoRca:=        GetValue<string> ('SEQRCA');
                            CoGerente:=    GetValue<string> ('SEQGERENTE');
                            NoSupervisor:= GetValue<string> ('NOME');
                            CoSituacao:=   GetValue<string> ('STATUS');
                       end;

                       with ClaSupervisor do begin
                            TRequest:= CheckSupervisor(CoSupervisor, TRequest);
                            if TRequest = TRequestType.rtPost then begin
                               QInsertInto:= QInsertInto +
                                             'INTO mxssuperv(codsupervisor, cod_cadrca, codgerente, nome, posicao)' +
                                             'VALUES' +
                                             '('''+CoSupervisor+''', '''+CoRca+''', '''+CoGerente+''', '''+NoSupervisor+''', '''+CoSituacao+''')'
                                           ;

                               if QReg = LReg then begin
                                  InsertSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao, Erro);
                                  TReg:= TReg - QReg;
                                  if TReg >= LReg then begin
                                     QReg:= 0;
                                     QInsertInto:= '';
                                  end;
                               end;

                               if TReg < LReg then begin
                                  LReg:= TReg;
                                  QReg:= 0;
                                  QInsertInto:= '';
                               end;

                            end else begin
                                UpdateSupervisores(CoSupervisor, CoRca, CoGerente, NoSupervisor, CoSituacao, Erro);
                            end;
                       end;
                   end;
              end;
           end;
           finally

       end;
    end;
end;
}
{ Ao criar o data m�dulo � os eventos s�o parametrizados }

procedure TfDmEventos.ServerMethodDataModuleCreate(Sender: TObject);
begin
    // Eventos api-cadan/cidades \\
    with DWECidades do begin
         ContextName:= 'api-cadan';
         with Events do begin
              Clear;
              Add.DisplayName             := 'cidades';
              Items[0].EventName          := 'cidades';
              Items[0].JsonMode           := jmPureJSON;
              Items[0].Name               := 'cidades';
              Items[0].OnReplyEventByType := DWServerEventsEventsAPICidades;
         end;
    end;
    {
    // Eventos api-cadan/pracas \\
    with DWEPracas do begin
         ContextName:= 'api-cadan';
         with Events do begin
              Clear;
              add.DisplayName             := 'pracas';
              items[0].EventName          := 'pracas';
              Items[0].JsonMode           := jmPureJSON;
              Items[0].Name               := 'pracas';
              Items[0].OnReplyEventByType := DWServerEventsEventsAPIPracas;
         end;
    end;

    // Eventos api-cadan/gerentes \\
    with DWEGerentes do begin
         ContextName:= 'api-cadan';
         with Events do begin
              Clear;
              add.DisplayName             := 'gerentes';
              items[0].EventName          := 'gerentes';
              Items[0].JsonMode           := jmPureJSON;
              Items[0].Name               := 'gerentes';
              Items[0].OnReplyEventByType := DWServerEventsEventsAPIGerentes;
         end;
    end;

    // Eventos api-cadan/suvervisores \\
    with DWESupervisores do begin
         ContextName:= 'api-cadan';
         with Events do begin
              Clear;
              add.DisplayName             := 'supervisores';
              items[0].EventName          := 'supervisores';
              Items[0].JsonMode           := jmPureJSON;
              Items[0].Name               := 'supervisores';
              Items[0].OnReplyEventByType := DWServerEventsEventsAPISupervisores;
         end;
    end;
    }
end;

end.
