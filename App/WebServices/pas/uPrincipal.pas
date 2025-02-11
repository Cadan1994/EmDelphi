{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Tela de ativar e desativar a conex�o do web service
 Data Cria��o........: 08/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.IniFiles,
  System.Net.HttpClient, System.Net.URLClient, System.NetConsts,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts,
  Data.DB, Data.Win.ADODB,
  uDWAbout, uRESTDWBase, ServerUtils, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Authenticator.Basic,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  uRESTDWPoolerDB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDWConstsData,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TfPrincipal = class(TForm)
    TrayIcon: TTrayIcon;
    imgWebServer: TImage;
    PopupMenu: TPopupMenu;
    Parametrizacao: TMenuItem;
    ManutencaoQuerys: TMenuItem;
    Maximizar: TMenuItem;
    shpAtivar: TShape;
    lblAtivar: TLabel;
    imgTop: TImage;
    lblTitulo: TLabel;
    imgIcon: TImage;
    imgMinimizar: TImage;
    imgFechar: TImage;
    imgLogo: TImage;
    Sobre: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure imgFecharClick(Sender: TObject);
    procedure imgMinimizarClick(Sender: TObject);
    procedure MaximizarClick(Sender: TObject);
    procedure imgMinimizarMouseEnter(Sender: TObject);
    procedure imgMinimizarMouseLeave(Sender: TObject);
    procedure lblAtivarClick(Sender: TObject);
    procedure imgIconMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SobreClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ParametrizacaoClick(Sender: TObject);
  private
    { Private declarations }
    HoraExecucao: string;
    {
    RESTServicePooler: TRESTServicePooler;
    RESTAuthenticator: THTTPBasicAuthenticator;
    RESTClient: TRESTClient;
    RESTRequestCidades,
    RESTRequestPracas,
    RESTRequestGerentes,
    RESTRequestSupervisores: TRESTRequest;
    }
    Timer: TTimer;
    //function AtivarWebServer(BAtivado: Boolean): Boolean;
    procedure TimerTimer(Sender: TObject);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

{$R *.dfm}

uses uParametrizacao, uSobre;

function CalcularHoras(HoraAtual: TDateTime): string;
var
    HoraTotal: TDateTime;
    Hora,
    Minuto,
    Segundo,
    HoraResult: string;
begin
    HoraTotal:= HoraAtual + StrToTime('00:05:00');
    HoraResult:= FormatDateTime('hh:nn:ss',HoraTotal);
    Hora:= Copy(HoraResult, 1, Pos(':', HoraResult) - 1);
    Minuto:= Copy(HoraResult, Pos(':', HoraResult) + 1, Pos(':', HoraResult) - 1);
    Segundo:= '00';
    Result:= Hora + ':' + Minuto + ':' + Segundo;
end;

function TelaMensagem(
              Botoes: Array of String;
              Mensagem: String = '';
              BtnPadrao: Integer = 1;
              Titulo: String = 'Aten��o';
              TipoDlg: TMsgDlgType = mtInformation;
              x: Integer = 0;
              y: Integer = 0
          ): Integer;
var
    Bt: TMsgDlgButtons;           { Recebe o tipo de bot�o }
    Btxt: Array[3..6] of String;  { Nao foi usado de 1..4 pois o "X" ou ALT+F4 = 2 }
    I,
    C: Integer;
begin
    { Zera var interna ... }
    for I:= 3 to 6 do Btxt[I]:= '';

    { Adiciona captions na var ... }
    for I:= Low(Botoes) to High(Botoes) do Btxt[I + 3]:= Botoes[I];

    Bt:= [];
    { Coloca na BT os bot�es do tipo mb... }
    for I:= 3 to 5 do
        if Btxt[I] <> '' then
           Bt:= Bt + [TMsgDlgBtn(I + 1)];

    if BTxt[6] <> '' then
       Bt:= Bt + [mbAll];

    { Cria MessageDlg ... }
    with CreateMessageDialog(Mensagem, TipoDlg, Bt) do
    try
        if x > 0 Then
           Top := x;
          if y > 0 Then
             left := y;
             { Define o caption ... }
             Caption:= Titulo;
             { Corre todos os seus componentes ... }
             for I:= 0 to ComponentCount - 1 do
                 { Se for bot�o ... }
                 if Components[I] is TButton then begin
                    { Caso o modal result dele � o mesmo do que foi criado, muda o caption ... }
                    C:= TButton(Components[I]).ModalResult;
                    if C = mrAll then
                       C:= 6;
                       TButton(Components[I]).Caption:= BTxt[C];

                    { Seta o bot�o padr�o ... }
                    if (BtnPadrao + 2) = TButton(Components[I]).ModalResult then
                       ActiveControl:= TButton(Components[I]);
                 end;
             Result:= ShowModal;
             { Caso pressionado ESC ou X ou ALT+F4 ent�o devolve "0" sen�o devolve 1 para 1� bot�o, 2 para 2� ... }
             if Result = 2 then
                Result:= 0
          else
             { Se foi mrAll = 6 fica sendo 4 ... }
             if Result = mrAll then
                Result:= 4
        else
            Result:= Result - 2;
        finally
            DisposeOf;
    end;
end;


{ Fun��o de ativar e desativar a conex�o do web service }
{
function TfPrincipal.AtivarWebServer(BAtivado: Boolean): Boolean;
var
    Ini: TIniFile;
    ArquivoINI: string;
    OAutenticacao: TRDWAuthOption;
begin
    Result:= BAtivado;

    ArquivoINI:= ExtractFilePath(Application.ExeName) + 'WSCadanCfg.ini';

    Ini:= TIniFile.Create(arquivoINI);
    try
        if not FileExists(ArquivoINI) then begin
               TelaMensagem(['Ok'], 'Arquivo INI n�o encontrado: ' + ArquivoINI, 1, 'Aten��o', mtWarning);
               exit;
        end;

        with Ini do begin
             WebServicesPort          := ReadString('WebServices', 'Port', WebServicesPort);
             WebServicesUserName      := ReadString('WebServices', 'UserName', WebServicesUserName);
             WebServicesPassword      := fDmBaseDados.Crypt('D',ReadString('WebServices', 'Password', WebServicesPassword));
             WebServicesURLOrigem     := ReadString('WebServices', 'URLOrigem', WebServicesURLOrigem);
             WebServicesURLDestino    := ReadString('WebServices', 'URLDestino', WebServicesURLDestino);
             WebServicesConnectTimeout:= ReadString('WebServices', 'ConnectTimeout', WebServicesConnectTimeout);
             WebServicesReadTimeout   := ReadString('WebServices', 'ReadTimeout', WebServicesReadTimeout);
        end;

        with RESTServicePooler do begin
             with AuthenticationOptions do begin
                  OAutenticacao:= rdwAOBasic;
                  AuthorizationOption:= OAutenticacao;
                  TRDWAuthOptionBasic(OptionParams).Username:= WebServicesUserName;
                  TRDWAuthOptionBasic(OptionParams).Password:= WebServicesPassword;
             end;
             ServicePort:= StrToInt(WebServicesPort);
             ServerMethodClass:= TfDmEventos;
             Active:= Result;
        end;

        with shpAtivar do begin
             Brush.Color:= RGB(45,55,111);
             Pen.Color:= RGB(45,55,111);
             with Timer do begin
                  OnTimer:= TimerTimer;
                  Interval:= 100;
                  if BAtivado = True then begin
                     lblAtivar.Caption:= 'Desativar';
                     Enabled:= True;
                  end else begin
                      lblAtivar.Caption:= 'Ativar';
                      Enabled:= False;
                  end;
             end;
        end;

        finally
            if Assigned(Ini) then
               Ini.DisposeOf;
    end;
end;
}
{ Procedimento para arrendondar os cantos do formul�rio }
procedure ArredondarForm(Control: TWinControl);
var
   R: TRect;
   Rgn: HRGN;
begin
    with Control do  begin
         R:= ClientRect;
         Rgn:= CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, 15, 15) ;
         Perform(EM_GETRECT, 0, lParam(@R)) ;
         InflateRect(R, - 4, - 4) ;
         Perform(EM_SETRECTNP, 0, lParam(@R)) ;
         SetWindowRgn(Handle, Rgn, True) ;
         Invalidate;
    end;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
//var
//    Erro: string;
begin
    //RESTServicePooler:= TRESTServicePooler.Create(nil);
    Timer:= TTimer.Create(nil);
    Timer.OnTimer:= TimerTimer;


    with fPrincipal do begin
         ClientHeight:= 450;
         ClientWidth:= 450;
         Color:= RGB(253,227,153);
         BorderStyle:= bsNone;
         Position:= poScreenCenter;
    end;
    ArredondarForm(fPrincipal);

    {
    AtivarWebServer(True);
    Erro:= fDmBaseDados.CarregarParametrosBD;
    if Erro <> 'OK' then
       ShowMessage(Erro);
    }
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
    //RESTServicePooler.DisposeOf;
    Timer.DisposeOf;
end;

procedure TfPrincipal.FormPaint(Sender: TObject);
var
    frmTamW: Integer;
begin
    frmTamW:= ClientWidth;

    with imgTop do begin
         Align:= alTop;
         Center:= True;
    end;

    with imgIcon do begin
         Left:= imgTop.Left + 25;
         Top:= imgTop.Top + 3;
    end;

    with lblTitulo do begin
         AutoSize:= True;
         with Font do begin
              Size:= 18;
              Name:= 'Calibri';
              Color:= RGB(255,255,255);
         end;
         Left:= imgIcon.Width + 30;
         Top:= imgIcon.Top;
         Caption:= 'Web Services';
    end;

    with imgFechar do begin
         Left:= frmTamW - (Width + 25);
         Top:= 5;
    end;

    with imgMinimizar do begin
         Left:= frmTamW - (imgFechar.Width + Width + 25);
         Top:= imgFechar.Top;
         OnClick(Self);
    end;

    with imgWebServer do begin
         Left:= frmTamW div 2 - (Width div 2);
         Top:= lblTitulo.Height + 30;
    end;

    with shpAtivar do begin
         Top:= imgWebServer.Top + imgLogo.Height + 20;
         Left:= frmTamW div 2 - (Width div 2);
         with lblAtivar do begin
              Top:= shpAtivar.Top;
              Left:= shpAtivar.Left;
              Height:= shpAtivar.Height;
              Width:= shpAtivar.Width;
              with Font do begin
                   Color:= RGB(255,255,255);
                   Name:= 'Calibri';
                   Size:= 12;
              end;
         end;
    end;

    with imgLogo do begin
         Left:= frmTamW div 2 - (Width div 2);
         Top:= shpAtivar.Top + shpAtivar.Height + 15;
    end;

    OnPaint:= nil;
end;

procedure TfPrincipal.imgFecharClick(Sender: TObject);
begin
    Application.Terminate;
end;

procedure TfPrincipal.imgIconMouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
    sc_DragMove = $f012;
begin
    ReleaseCapture;
    Perform(wm_SysCommand, sc_DragMove, 0);
end;

procedure TfPrincipal.imgMinimizarClick(Sender: TObject);
begin
    Self.Hide();
    Self.WindowState:= wsMinimized;
    with TrayIcon do begin
         Visible:= True;
         Animate:= True;
         ShowBalloonHint;
    end;
end;

procedure TfPrincipal.imgMinimizarMouseEnter(Sender: TObject);
begin
    Cursor:= crHandPoint;
end;

procedure TfPrincipal.imgMinimizarMouseLeave(Sender: TObject);
begin
    Cursor:= crDefault;
end;

procedure TfPrincipal.lblAtivarClick(Sender: TObject);
begin

    {
    if RESTServicePooler.Active then
       AtivarWebServer(False)
    else
        AtivarWebServer(True)
    }
end;

procedure TfPrincipal.MaximizarClick(Sender: TObject);
begin
    TrayIcon.Visible:= False;
    Show();
    WindowState:= wsNormal;
    Application.BringToFront();
end;

procedure TfPrincipal.ParametrizacaoClick(Sender: TObject);
begin
    { Cria o formul�rio parametriza��o }
    fParametrizacao:= TfParametrizacao.Create(Application);
    with fParametrizacao do begin
         ClientHeight:= 400;
         ClientWidth:= 450;
         Color:= RGB(253,227,153);
         BorderStyle:= bsNone;
         Position:= poScreenCenter;
         ShowModal;
         FreeAndNil(fParametrizacao);
    end;
end;

procedure TfPrincipal.SobreClick(Sender: TObject);
begin
    { Cria o formul�rio sobre }
    fSobre:= TfSobre.Create(Application);
    with fSobre do begin
         ClientHeight:= 400;
         ClientWidth:= 450;
         Color:= RGB(253,227,153);
         BorderStyle:= bsNone;
         Position:= poScreenCenter;
         ShowModal;
         FreeAndNil(fSobre);
    end;
end;

procedure TfPrincipal.TimerTimer(Sender: TObject);
var
    HoraAtual: TTime;
    Dados,
    Hora,
    Minuto,
    Segundo,
    TempoExecucao: string;
    Http: THttpClient;
    HttpResponse: IHttpResponse;
begin
    HoraAtual:= Time;
    Hora:= Copy(TimeToStr(HoraAtual), 1, Pos(':', TimeToStr(HoraAtual)) - 1);
    Minuto:= Copy(TimeToStr(HoraAtual), Pos(':', TimeToStr(HoraAtual)) + 1, Pos(':', TimeToStr(HoraAtual)) - 1);
    Segundo:= '00';
    TempoExecucao:= Hora + ':' + Minuto + ':' + Segundo;

    if Length(Trim(HoraExecucao)) = 0 then begin
       Minuto:= Copy(TimeToStr(HoraAtual), Pos(':', TimeToStr(HoraAtual)) + 1, Pos(':', TimeToStr(HoraAtual)) - 2) + '0';
       TempoExecucao:= Hora + ':' + Minuto + ':' + Segundo;
       HoraExecucao:= TempoExecucao;
    end;

    if StrToTime(TempoExecucao) > StrToTime(HoraExecucao) then
       HoraExecucao:= CalcularHoras(StrToTime(HoraExecucao));


    if TempoExecucao = HoraExecucao then begin
       HoraExecucao:= CalcularHoras(StrToTime(TempoExecucao));
       Http:= THTTPClient.Create;
       try
           with Http do begin
                ContentType:= 'application/json';
                Accept:= 'application/json';
                HttpResponse:= Get('http://127.0.0.1:8000/cidades');
                HttpResponse:= Get('http://127.0.0.1:8000/pracas');
           end;
           Dados:= HttpResponse.ContentAsString();
           finally
               Http.DisposeOf;
       end;
    end;
end;

end.
