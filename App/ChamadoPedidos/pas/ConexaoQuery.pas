unit ConexaoQuery;

interface

uses
  System.SysUtils, System.Classes, Vcl.OleServer, Vcl.CmAdmCtl, Data.DB, System.IniFiles,
  Data.Win.ADODB, Vcl.ExtCtrls, Vcl.Menus, FireDAC.Stan.Intf, Vcl.Forms,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.DBClient, ShellAPI, Windows,
  Data.SqlExpr, Data.FMTBcd, FireDAC.Phys.PG, FireDAC.Phys.PGDef;

type
  TDM = class(TDataModule)
    ADOConnection: TADOConnection;
    ADOQuery1: TADOQuery;
    FDConnection: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    FDQuery1: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

  private
    { Private declarations }
    Contador: Integer;
    function CarregarParametros: string;
  public
    { Public declarations }
    { POSTGRESQL }
    DRPostgres,
    HNPostgres,
    PTPostgres,
    DBPostgres,
    SNPostgres,
    UNPostgres,
    PWPostgres,
    { ORACLE }
    PNOracle,
    DBOracle,
    UNOracle,
    PWOracle: string;
    Procedure ConexaoBancoDados;
    Procedure PedidosLiberadosInsert;
    Procedure PedidosFaturadosDelete;
    Procedure ChamarClientePagamento;
    Function EncaminharCaixa(a: String): String;
    function PrimeiraLetraMaiusculaNome(Texto: string): string;
  end;

var
  DM : TDM;
  Trans: TTransactionDesc;
  Operacao,
  OperacaoReinicio: Integer;
  NomeClienteSelect,
  StatusSelect,
  Resposta,
  CodMemory,
  StaMemory,
  FpgMemory,
  Caixa,
  Caixa01,
  Caixa02,
  Caixa03,
  ImgMarket,
  ImgConvert,
  Extensao,
  Timer1Pedidos,
  Timer1Pesquisa,
  Timer1Chamada,
  Timer2Chamada,
  Timer3Chamada,
  Timer4Chamada,
  Timer1Principal: String;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses TelaPrincipal, UnitChamadaFinal;

{$R *.dfm}


{ TDM }

function PrimeiroNome (Nome : String) : String;
Var
    Caracteres: Integer;
Begin
    Caracteres:= Pos(' ', Nome);
    If Caracteres > 0 Then
       Result:= Copy(Nome, 1, Caracteres - 1)
    Else
       Result:= Nome;
end;



function TDM.PrimeiraLetraMaiusculaNome(Texto: string): string;
begin
    Result:= '';
    if Trim(Texto) <> '' then
       Result:= UpperCase(Copy(Texto,1,1))+LowerCase(Copy(Texto,2,Length(Texto)));
end;



function MapearRede(User, Password: PWideChar): string;
var
    nrw: TNetResource;
begin
    with NRW do begin
         dwType:= RESOURCETYPE_ANY;
         lpLocalName:= 'A:';
         lpRemoteName:= '\\172.16.157.3\App\DBDados';
         lpProvider:= '';
    end;
    WNetAddConnection2(nrw, Password, User, CONNECT_UPDATE_PROFILE);

    with NRW do begin
         dwType:= RESOURCETYPE_ANY;
         lpLocalName:= 'B:';
         lpRemoteName:= '\\172.16.157.3\App\ImgMarketing';
         lpProvider:= '';
    end;
    WNetAddConnection2(nrw, Password, User, CONNECT_UPDATE_PROFILE);

    with NRW do begin
         dwType:= RESOURCETYPE_ANY;
         lpLocalName:= 'Z:';
         lpRemoteName:= '\\192.168.168.19\ecommerce\imgsis';
         lpProvider:= '';
    end;
    WNetAddConnection2(nrw, Password, User, CONNECT_UPDATE_PROFILE);
end;

function RemoveMapeamento(): string;
begin
    WNetCancelConnection2('A:', CONNECT_UPDATE_PROFILE, True);
    WNetCancelConnection2('B:', CONNECT_UPDATE_PROFILE, True);
    WNetCancelConnection2('Z:', CONNECT_UPDATE_PROFILE, True);
end;

function Crypt(Action, Src: String): String;
Label
        Fim;
var
        KeyLen,
        KeyPos,
        OffSet,
        SrcPos,
        SrcAsc,
        TmpSrcAsc,
        Range:     Integer;
        Dest,
        Key:       String;
begin
        if (Src = '') then begin
           Result:= '';
           Goto Fim;
        end;
        Key:= '1234567890!@#$%�&*()ABCDEFGHIJLKMNOPQRSTUVXZYW';
        Dest:= '';
        KeyLen:= Length(Key);
        KeyPos:= 0;
        Range:= 255;

        {Criptografar}
        if (Action = UpperCase('C')) then begin
            Randomize;
            OffSet:= Random(Range);
            Dest:= Format('%1.2x',[OffSet]);
            for SrcPos:= 1 to Length(Src) do begin
                Application.ProcessMessages;
                SrcAsc:= (Ord(Src[SrcPos]) + OffSet) Mod 255;
                if KeyPos < KeyLen then KeyPos:= KeyPos + 1 else KeyPos:= 1;
                SrcAsc:= SrcAsc Xor Ord(Key[KeyPos]);
                Dest:= Dest + Format('%1.2x',[SrcAsc]);
                OffSet:= SrcAsc;
            end;
        end else begin
            {Descriptografar}
            if (Action = UpperCase('D')) then begin
                OffSet:= StrToInt('$'+ copy(Src,1,2));
                SrcPos:= 3;
                repeat
                SrcAsc:= StrToInt('$'+ copy(Src,SrcPos,2));
                if (KeyPos < KeyLen) Then KeyPos:= KeyPos + 1 else KeyPos:= 1;
                TmpSrcAsc:= SrcAsc Xor Ord(Key[KeyPos]);
                if TmpSrcAsc <= OffSet then
                   TmpSrcAsc := 255 + TmpSrcAsc - OffSet
                   else
                     TmpSrcAsc:= TmpSrcAsc - OffSet;
                     Dest:= Dest + Chr(TmpSrcAsc);
                     OffSet:= SrcAsc;
                     SrcPos:= SrcPos + 2;
                     until (SrcPos >= Length(Src));
            end;
        end;
        Result:= Dest;
        Fim:
end;


function TDM.CarregarParametros(): string;
var
    ini: TIniFile;
    arquivoINI: string;
begin
    arquivoINI:= System.SysUtils.GetCurrentDir + '\ProjetoCPCfg.ini';
    ini:= TIniFile.Create(arquivoINI);
    try
        if not FileExists(arquivoINI) then begin
               Result:= 'Arquivo INI n�o encontrado: ' + arquivoINI;
               exit;
        end;

        with ini do begin
             { PARAMETROS DE CONEX�O POSTGRESQL }
             DRPostgres:= ReadString('PostgreSQL', 'DriverId', DRPostgres);
             HNPostgres:= ReadString('PostgreSQL', 'HostName', HNPostgres);
             PTPostgres:= ReadString('PostgreSQL', 'Port', PTPostgres);
             DBPostgres:= ReadString('PostgreSQL', 'Database', DBPostgres);
             SNPostgres:= ReadString('PostgreSQL', 'SchemaName', SNPostgres);
             UNPostgres:= ReadString('PostgreSQL', 'UserName', UNPostgres);
             PWPostgres:= ReadString('PostgreSQL', 'Password', PWPostgres);
             { PARAMETROS DE CONEX�O ORACLE }
             PNOracle:= ReadString('Oracle', 'Provider', PNOracle);
             DBOracle:= ReadString('Oracle', 'DataSource', DBOracle);
             UNOracle:= ReadString('Oracle', 'UserName', UNOracle);
             PWOracle:= ReadString('Oracle', 'Password', PWOracle);
             { PARAMETRO CAIXAS }
             Caixa01:=   ReadString('Caixa', 'Cxa01', Caixa01);
             Caixa02:=   ReadString('Caixa', 'Cxa02', Caixa02);
             Caixa03:=   ReadString('Caixa', 'Cxa03', Caixa03);
             { PARAMETRO IMAGENS }
             ImgMarket:= ReadString('Imagens', 'ImgMarket', ImgMarket);
             ImgConvert:= ReadString('Imagens', 'ImgConvert', ImgConvert);
             Extensao:= ReadString('Imagens', 'Extensao', Extensao);
             { PARAMETRO TIMER'S }
             Timer1Pedidos:=  ReadString('Timers','Timer1Pedido',   Timer1Pedidos);
             Timer1Pesquisa:= ReadString('Timers','Timer1Pesquisa', Timer1Pesquisa);
             Timer1Chamada:= ReadString('Timers','Timer1Chamada', Timer1Chamada);
             Timer2Chamada:= ReadString('Timers','Timer2Chamada', Timer2Chamada);
             Timer3Chamada:= ReadString('Timers','Timer3Chamada', Timer3Chamada);
             Timer4Chamada:= ReadString('Timers','Timer4Chamada', Timer4Chamada);
             Timer1Principal:= ReadString('Timers','Timer1Principal', Timer1Principal);
        end;

        finally
            if Assigned(ini) then
               ini.DisposeOf;
    end;
end;

procedure TDM.ConexaoBancoDados;
var
    DiretorioDll: string;
begin
    DiretorioDll:= System.SysUtils.GetCurrentDir;
    with ADOConnection do begin
         Connected:= False;
         ConnectionString:= 'Provider='+PNOracle+';'
                          + 'Data Source='+DBOracle+';'
                          + 'User Id='+UNOracle+';'
                          + 'Password='+Crypt('D',PWOracle)+';'
                          ;
         LoginPrompt:=False;
         Connected:= True;
    end;
    ADOQuery1.Connection:= ADOConnection;

    with FDConnection do begin
         DriverName:= DRPostgres;
         LoginPrompt:= False;
         with Params do begin
              Database:= DBPostgres;
              UserName:= UNPostgres;
              Password:= Crypt('D', PWPostgres);
              Values['DriverID']:= DRPostgres;
              Values['MetaDefSchema']:= SNPostgres;
              //Add('Server=172.16.157.3');
              //Add('Port=2899');
              //Values['Server']:= HNPostgres;
              //Values['Port']:= PTPostgres;
         end;
         FDPhysPgDriverLink.VendorHome:= DiretorioDll;
         Connected:= True;
    end;
end;

procedure TDM.ChamarClientePagamento;
var
    CodCaixa: string;
    CodOrdem: Integer;
begin
    if Caixa01 = Caixa then begin
       CodCaixa:= '01';
    end else begin;
        if Caixa02 = Caixa then begin
           CodCaixa:= '02';
        end else begin
            CodCaixa:= '03';
        end;
    end;
    With FDConnection do begin
         StartTransaction;
         Try
            with FDQuery1 do begin
                 Close;
                 with SQL do begin
                      case Operacao of
                           1: begin
                                  if Resposta = 'S' then begin
                                     Clear;
                                     Add('SELECT "CodOrdem" '
                                        +'FROM cadan."CLICHAMADOS" '
                                        +'WHERE 1=1 '
                                        +'ORDER BY "CodOrdem" DESC '
                                        +'LIMIT 1'
                                     );
                                     Prepared:= True;
                                     Open;
                                     First;
                                     CodOrdem := Fields[0].AsInteger + 1;

                                     Clear;
                                     Add('UPDATE cadan."CLICHAMADOS" '
                                        +'SET "Status" = :Status, "CodOrdem" = :CodOrdem, "Caixa" = :Caixa, "Mac" = :CodMac '
                                        +'WHERE "RazaoSocial" = :RazaoSocial AND "FormaPagto" = :FormaPagto'
                                     );
                                     with Params do begin
                                          ParamByName('RazaoSocial').Value:= CodMemory;
                                          ParamByName('Status').Value:= 'A';
                                          ParamByName('CodOrdem').Value:= CodOrdem;
                                          ParamByName('Caixa').Value:= '0';
                                          ParamByName('CodMac').Value:= '0';
                                          ParamByName('FormaPagto').Value:= FpgMemory;
                                     end;
                                     Prepared:= True;
                                     ExecSQL;

                                     Clear;
                                     Add('UPDATE cadan."CLICHAMADOS" '
                                        +'SET "Status" = :Status, "Caixa" = :Caixa, "Mac" = :CodMac '
                                        +'WHERE "RazaoSocial" = :RazaoSocial AND "FormaPagto" = :FormaPagto'
                                     );
                                     with Params do begin
                                          ParamByName('RazaoSocial').Value:= NomeClienteSelect;
                                          ParamByName('Status').Value:= 'C';
                                          ParamByName('Caixa').Value:= CodCaixa;
                                          ParamByName('CodMac').Value:= Caixa;
                                          ParamByName('FormaPagto').Value:= Fmpagto;
                                     end;
                                     Prepared:= True;
                                     ExecSQL;
                                  end else begin
                                      Clear;
                                      Add('UPDATE cadan."CLICHAMADOS" '
                                         +'SET "Status" = :Status, "Caixa" = :Caixa, "Mac" = :CodMac '
                                         +'WHERE "RazaoSocial" = :RazaoSocial AND "FormaPagto" = :FormaPagto'
                                      );
                                      with Params do begin
                                           ParamByName('RazaoSocial').Value:= NomeClienteSelect;
                                           ParamByName('Status').Value:= 'C';
                                           ParamByName('Caixa').Value:= CodCaixa;
                                           ParamByName('CodMac').Value:= Caixa;
                                           ParamByName('FormaPagto').Value:= Fmpagto;
                                      end;
                                      Prepared:= True;
                                      ExecSQL;
                                      StaMemory:= 'C';
                                      CodMemory:= NomeClienteSelect;
                                  end;
                              end;
                           2: begin
                                  Clear;
                                  Add('UPDATE cadan."CLICHAMADOS" '
                                     +'SET "Status" = :Status, "Caixa" = :Caixa, "Mac" = :CodMac '
                                     +'WHERE "RazaoSocial" = :RazaoSocial AND "FormaPagto" = :FormaPagto'
                                  );
                                  with Params do begin
                                       ParamByName('RazaoSocial').Value:= NomeClienteSelect;
                                       ParamByName('Status').Value:= 'L';
                                       ParamByName('Caixa').Value:= '0';
                                       ParamByName('CodMac').Value:= '0';
                                       ParamByName('FormaPagto').Value:= Fmpagto;
                                  end;
                                  Prepared:= True;
                                  ExecSQL;
                                  StaMemory:= 'L';
                              end;
                      end;
                 end;
            end;
            Commit;
            except
                RollBack;
         end;
    end;
end;

procedure TDM.PedidosFaturadosDelete;
var
    CodPedido: String;
begin
    with ADOQuery1 do begin
         Close;
         with SQL do begin
              Clear;
              Add('SELECT A.NROPEDVENDA '
                 +'FROM IMPLANTACAO.MAD_PEDVENDA A '
                 +'INNER JOIN IMPLANTACAO.MRL_CARGAEXPED B '
                 +'ON B.NROCARGA = A.NROCARGA '
                 +'AND B.STATUSCARGA = ''F'' '
                 +'AND B.DTALIBFATURA >= ADD_MONTHS(TRUNC(SYSDATE,''DD''),0)-3 '
                 +'WHERE 1=1 '
                 +'AND A.NROEMPRESA = ''1'' '
                 +'AND A.SEQPESSOA NOT IN (1,22401) '
                 +'AND A.INDENTREGARETIRA = ''R'' '
                 +'ORDER BY B.DTALIBFATURA ASC')
                 ;
         end;
         Open;
         First;
         if not IsEmpty then begin
                while not Eof do begin
                          CodPedido:= Fields[0].AsString;
                          with FDConnection do begin
                               StartTransaction;
                               try
                                  with FDQuery1 do begin
                                       Close;
                                       with SQL do begin
                                            Clear;
                                            Add('DELETE '
                                               +'FROM cadan."CLICHAMADOS" '
                                               +'WHERE "CodPedido" = '''+CodPedido+''''
                                            );
                                            Prepared:= True;
                                            ExecSQL;
                                       end;
                                       Close;
                                  end;
                                  Commit;
                                  except
                                      Rollback;
                               end;
                          end;
                          Next;
                end;
         end;
         Close;
    end;
end;

function TDM.EncaminharCaixa(a: String): String;
Var
  RSocial,
  CodPedido,
  RazaoSocial,
  NomeFantasia,
  DtaLib,
  FormaPagto,
  Status: String;
  COrdem,
  CodOrdem : Integer;
begin
    CodOrdem:= 1;
    with FDConnection do begin
         StartTransaction;
         try
            with FDQuery1 do begin
                 Close;
                 with SQL do begin
                      Clear;
                      Add('SELECT '
                         +'    "CodPedido",'
                         +'    CASE WHEN "RazaoSocial" = ''Consumidor Final'' THEN "RazaoSocial" ||''-''|| "CodPedido" ELSE "RazaoSocial" END AS "RazaoSocial",'
                         +'    "NomeFantasia",'
                         +'    "DtaLib",'
                         +'    "FormaPagto",'
                         +'    "Status" '
                         +'FROM cadan."CLILIBERADOS" '
                         +'WHERE 1=1 '
                         +'AND "CodPedido" = '''+a+''''
                      );
                      Prepared:= True;
                      Open;
                      CodPedido:= Fields[0].AsString;
                      RazaoSocial:= Fields[1].AsString;
                      NomeFantasia:= Fields[2].AsString;
                      DtaLib:= Fields[3].AsString;
                      FormaPagto:= Fields[4].AsString;
                      Status:= Fields[5].AsString;

                      Clear;
                      Add('SELECT DISTINCT "CodOrdem" '
                         +'FROM cadan."CLICHAMADOS" '
                         +'WHERE 1=1 '
                         +'ORDER BY "CodOrdem" DESC '
                         +'LIMIT 1;'
                      );
                      Prepared:= True;
                      Open;
                      if not IsEmpty then begin
                             CodOrdem:= Fields[0].AsInteger;
                             Clear;
                             Add('SELECT "CodOrdem","RazaoSocial" '
                                +'FROM cadan."CLICHAMADOS" '
                                +'WHERE 1=1 '
                                +'AND "RazaoSocial" LIKE '''+Trim(RazaoSocial)+'%'' '
                                +'ORDER BY "CodOrdem" DESC '
                                +'LIMIT 1;'
                             );
                             Prepared:= True;
                             Open;
                             First;
                             COrdem:= Fields[0].AsInteger;
                             RSocial:= Fields[1].AsString;
                             if Trim(RSocial) = Trim(RazaoSocial) then begin
                                CodOrdem:= COrdem;
                             end else begin
                                 CodOrdem:= CodOrdem + 1;
                             end;
                      end;

                      Clear;
                      Add('INSERT INTO cadan."CLICHAMADOS"'
                         +'("CodPedido","RazaoSocial","NomeFantasia","DtaLib","CodOrdem","QtdaChamada","FormaPagto","Status")'
                         +'VALUES'
                         +'(:CodPedido,:RazaoSocial,:NomeFantasia,:DtaLib,:CodOrdem,0,:FormaPagto,:Status)'
                      );
                      with Params do begin
                           ParamByName('CodPedido').Value:= StrToInt(Codpedido);
                           ParamByName('RazaoSocial').Value:= RazaoSocial;
                           ParamByName('NomeFantasia').Value:= NomeFantasia;
                           ParamByName('DtaLib').Value:= DtaLib;
                           ParamByName('CodOrdem').Value:= CodOrdem;
                           ParamByName('FormaPagto').Value:= FormaPagto;
                           ParamByName('Status').Value:= Status;
                      end;
                      Prepared:= True;
                      ExecSQL;

                      Clear;
                      Add('DELETE '
                         +'FROM cadan."CLILIBERADOS" '
                         +'WHERE "CodPedido" = :CodPedido'
                      );
                      Params.ParamByName('CodPedido').Value:= StrToInt(Codpedido);
                      Prepared:= True;
                      ExecSQL;
                 end;
                 Close;
            end;
            Commit;
            except
                Rollback;
         end;
         Connected:= False;
    end;
end;

procedure TDM.PedidosLiberadosInsert;
var
    CodPedido,
    DtaLib,
    RazaoSocial,
    NomeFantasia,
    FormaPagamento,
    StatusCargas: String;
begin
    with ADOQuery1 do begin
         Close;
         with SQL do begin
              Clear;
              Add('SELECT '
                 +'    A.NROPEDVENDA,'
                 +'    A.DTAINCLUSAO,'
                 +'    B.STATUSCARGA,'
                 +'    B.DTALIBFATURA,'
                 +'    INITCAP(C.NOMERAZAO) NOMERAZAO,'
                 +'    INITCAP(C.FANTASIA) FANTASIA,'
                 +'    INITCAP(D.FORMAPAGTO) FORMAPAGTO '
                 +'FROM IMPLANTACAO.MAD_PEDVENDA A '
                 +'INNER JOIN IMPLANTACAO.MRL_CARGAEXPED B '
                 +'ON B.NROCARGA = A.NROCARGA '
                 +'AND B.STATUSCARGA = ''L'' '
                 +'AND B.DTALIBFATURA >= ADD_MONTHS(TRUNC(SYSDATE,''DD''),0)-3 '
                 +'INNER JOIN IMPLANTACAO.GE_PESSOA C '
                 +'ON C.SEQPESSOA = A.SEQPESSOA '
                 +'INNER JOIN IMPLANTACAO.MRL_FORMAPAGTO D '
                 +'ON D.NROFORMAPAGTO = A.NROFORMAPAGTO '
                 +'WHERE 1=1 '
                 +'AND A.NROEMPRESA = ''1'' '
                 +'AND A.SEQPESSOA NOT IN (1, 22401) '
                 +'AND A.INDENTREGARETIRA = ''R'' '
                 +'ORDER BY B.DTALIBFATURA ASC');
              Open;
              First;
              while not eof do begin
                    CodPedido:= Fields[0].AsString;
                    StatusCargas:=Fields[2].AsString;
                    DtaLib:= Fields[3].AsString;
                    RazaoSocial:= Fields[4].AsString;
                    NomeFantasia:= Fields[5].AsString;
                    FormaPagamento:= Fields[6].AsString;

                    with FDConnection do begin
                         StartTransaction;
                         try
                             with FDQuery1 do begin
                                  Connection:= FDConnection;
                                  Close;
                                  with SQL do begin
                                       Clear;
                                       Add('SELECT * '
                                          +'FROM cadan."CLICHAMADOS" '
                                          +'WHERE 1=1 '
                                          +'AND "CodPedido" = '''+CodPedido+''''
                                       );
                                       Prepared:= True;
                                       Open;
                                       if IsEmpty then begin
                                          Clear;
                                          Add('SELECT * '
                                             +'FROM cadan."CLILIBERADOS" '
                                             +'WHERE 1=1 '
                                             +'AND "CodPedido" = '''+CodPedido+''''
                                          );
                                          Prepared:= True;
                                          Open;
                                          if IsEmpty then begin
                                             Clear;
                                             Add('INSERT INTO cadan."CLILIBERADOS"'
                                                +'("CodPedido","StatusCargas","DtaLib","RazaoSocial","NomeFantasia","FormaPagto","Status") '
                                                +'VALUES'
                                                +'(:CodPedido,:StatusCargas,:DtaLib,:RazaoSocial,:NomeFantasia,:FormaPagto,:Status)');
                                             with Params do begin
                                                  ParamByName('CodPedido').Value:= StrToInt(CodPedido);
                                                  ParamByName('StatusCargas').Value:= StatusCargas;
                                                  ParamByName('DtaLib').Value:= DtaLib;
                                                  ParamByName('RazaoSocial').Value:= RazaoSocial;
                                                  ParamByName('NomeFantasia').Value:= NomeFantasia;
                                                  ParamByName('FormaPagto').Value:= FormaPagamento;
                                                  ParamByName('Status').Value:= 'A';
                                             end;
                                             Prepared:= True;
                                             ExecSQl;
                                          end;
                                       end;
                                  end;
                                  Close;
                             end;
                             Commit;
                             except
                                 Rollback;
                         end;
                    end;
                    Next;
              end;
         end;
         Close;
    end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
    MapearRede('gsistema','C@dan.2023');
    CarregarParametros;
    ConexaoBancoDados;
    Contador:= 0;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
    RemoveMapeamento;
    ADOConnection.Connected:= False;
    FDConnection.Connected:= False;
end;

end.
