{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Reposit�rio de conex�es com bancos de dados dos sistema de integra��o do da
 Maxima e ERP Concinco
 Data Cria��o........: 03/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uDmBaseDados;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.IniFiles,
  vcl.Forms, Data.DB, Data.Win.ADODB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG, FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TfDmBaseDados = class(TDataModule)
    connConcinco: TADOConnection;
    connAplicativo: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    connMaxima: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Crypt(Action, Src: String): String;
    function CarregarParametrosBD: string;
  end;

var
  fDmBaseDados: TfDmBaseDados;
  PostgresQuery,
  WebServicesPort,
  WebServicesUserName,
  WebServicesPassword,
  WebServicesURLOrigem,
  WebServicesURLDestino,
  WebServicesConnectTimeout,
  WebServicesReadTimeout,
  COracleProvider,
  COracleDataSource,
  COracleUserName,
  COraclePassword,
  MOracleProvider,
  MOracleDataSource,
  MOracleUserName,
  MOraclePassword,
  PostgresDriver,
  PostgresHostName,
  PostgresPort,
  PostgresDatabase,
  PostgresShemaName,
  PostgresUserName,
  PostgresPassword: string;
const
  LimiteRegistro = 1000;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uSplash, uPrincipal;

{$R *.dfm}

{ Fun��o para criptografar e descriptografar senhas }
function TfDmBaseDados.Crypt(Action, Src: String): String;
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

    { Criptografar }
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
    end;

    { Descriptografar }
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

    Result:= Dest;
    Fim:
end;

{ Essa fun��o carrega os par�metros de conex�o com os banco de dados }
function TfDmBaseDados.CarregarParametrosBD(): string;
var
    Ini: TIniFile;
    ArquivoINI: string;
    DiretorioDll: string;
begin
    { Pega o caminho do arquivo execut�vel }
    DiretorioDll:= ExtractFilePath(Application.ExeName);

    { Paga o arquivo de configura��o }
    ArquivoINI:= DiretorioDll + 'WSCadanCfg.ini';

    { Est�ncia o objeto }
    Ini:= TIniFile.Create(arquivoINI);
    try
        { Verifica se o arquivo de configura��o existe }
        if not FileExists(ArquivoINI) then begin
               Result:= 'Arquivo INI n�o encontrado: ' + arquivoINI;
               exit;
        end;

        { Atribui as vari�veis os par�metros de configura��es }
        with Ini do begin
             { par�metros de conex�o com banco de dados PostgreSQL }
             PostgresDriver:=       ReadString('PostgreSQL', 'DriverId', PostgresDriver);
             PostgresHostName:=     ReadString('PostgreSQL', 'HostName', PostgresHostName);
             PostgresPort:=         ReadString('PostgreSQL', 'Port', PostgresPort);
             PostgresDatabase:=     ReadString('PostgreSQL', 'Database', PostgresDatabase);
             PostgresShemaName:=    ReadString('PostgreSQL', 'SchemaName', PostgresShemaName);
             PostgresUserName:=     ReadString('PostgreSQL', 'UserName', PostgresUserName);
             PostgresPassword:=     Crypt('D',ReadString('PostgreSQL', 'Password', PostgresPassword));

             { par�metros de conex�o com banco de dados Oracle CONCINCO }
             COracleProvider:=       ReadString('CONCINCO', 'Provider', COracleProvider);
             COracleDataSource:=     ReadString('CONCINCO', 'DataSource', COracleDataSource);
             COracleUserName:=       ReadString('CONCINCO', 'UserName', COracleUserName);
             COraclePassword:=       Crypt('D',ReadString('CONCINCO', 'Password', COraclePassword));

             { par�metros de conex�o com banco de dados Oracle MAXIMA }
             MOracleProvider:=       ReadString('MAXIMA', 'Provider', MOracleProvider);
             MOracleDataSource:=     ReadString('MAXIMA', 'DataSource', MOracleDataSource);
             MOracleUserName:=       ReadString('MAXIMA', 'UserName', MOracleUserName);
             MOraclePassword:=       Crypt('D',ReadString('MAXIMA', 'Password', MOraclePassword));
        end;

        try
            { Conex�o com banco de dados CONSINCO }
            with connConcinco do begin
                 Connected:= False;
                 ConnectionString:= 'Provider='+COracleProvider+';'
                                  + 'Data Source='+COracleDataSource+';'
                                  + 'User Id='+COracleUserName+';'
                                  + 'Password='+COraclePassword+';'
                                  ;
                 LoginPrompt:=False;
                 Provider:= 'MSDAORA';
                 Connected:= True;
            end;

            { Conex�o com banco de dados MAXIMA }
            with connMaxima do begin
                 Connected:= False;
                 ConnectionString:= 'Provider='+MOracleProvider+';'
                                  + 'Data Source='+MOracleDataSource+';'
                                  + 'User Id='+MOracleUserName+';'
                                  + 'Password='+MOraclePassword+';'
                                  ;
                 LoginPrompt:=False;
                 Provider:= 'MSDAORA';
                 Connected:= True;
            end;

            { Conex�o com banco de dados MAXIMA }
            with connAplicativo do begin
                 DriverName:= PostgresDriver;
                 LoginPrompt:= False;
                 with Params do begin
                      Database:= PostgresDatabase;
                      UserName:= PostgresUserName;
                      Password:= PostgresPassword;
                      Values['DriverID']:= PostgresDriver;
                      Values['MetaDefSchema']:= PostgresShemaName;
                 end;
                 FDPhysPgDriverLink.VendorHome:= DiretorioDll;
                 Connected:= True;
            end;
            Result:= 'OK';
        except on Ex:Exception do
            Result:= 'Erro ao acessar o banco de dados: ' + Ex.Message;
        end;

        finally
            if Assigned(Ini) then
               Ini.DisposeOf;
    end;
end;

procedure TfDmBaseDados.DataModuleCreate(Sender: TObject);
begin
    { Cria, chama e destroi a tela de splash }
    fSplash:= TfSplash.Create(Application);
    with fSplash do begin
         ClientHeight:= 450;
         ClientWidth:= 450;
         Color:= RGB(253,227,153);
         BorderStyle:= bsNone;
         Position:= poScreenCenter;
         Show;
         Refresh;
         Update;
         Sleep(5000);
         Application.CreateForm(TfPrincipal, fPrincipal);
         fSplash.Hide;
         fSplash.Release;
         FreeAndNil(fSplash);
    end;
end;

end.
