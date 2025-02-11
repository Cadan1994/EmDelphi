unit TelaPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.Win.ADODB, Vcl.Grids,
  Datasnap.DBClient, Datasnap.Provider, Vcl.DBGrids, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Imaging.jpeg, Vcl.AppAnalytics,
  Vcl.VirtualImage, Vcl.BaseImageCollection, Vcl.ImageCollection,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.AppEvnts,
  Vcl.Menus, Data.SqlExpr;

type
  TfrmPrincipal = class(TForm)
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    PopupMenu: TPopupMenu;
    Fechar: TMenuItem;
    VisualizarPedidos: TMenuItem;
    TelaChamados: TMenuItem;
    PedidosLiberados1: TMenuItem;
    Timer1: TTimer;
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VisualizarPedidosClick(Sender: TObject);
    procedure FecharClick(Sender: TObject);
    procedure TelaChamadosClick(Sender: TObject);
    procedure PedidosLiberados1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  AHeight,
  LWidth,
  ScreenCount: Integer;
  Fmpagto,
  CodMac: string;



implementation

{$R *.dfm}

uses ConexaoQuery, UnitChamadaFinal, TelaPedidos, TelaPesquisa;

function MacAddress: string;
var
    Lib: Cardinal;
    Func: function(GUID: PGUID): Longint; stdcall;
    GUID1, GUID2: TGUID;
begin
    Result := '';
    Lib := LoadLibrary('rpcrt4.dll');
    if Lib <> 0 then
    begin
        @Func := GetProcAddress(Lib, 'UuidCreateSequential');
        if Assigned(Func) then begin
           if (Func(@GUID1) = 0) and
              (Func(@GUID2) = 0) and
              (GUID1.D4[2] = GUID2.D4[2]) and
              (GUID1.D4[3] = GUID2.D4[3]) and
              (GUID1.D4[4] = GUID2.D4[4]) and
              (GUID1.D4[5] = GUID2.D4[5]) and
              (GUID1.D4[6] = GUID2.D4[6]) and
              (GUID1.D4[7] = GUID2.D4[7]) then
              begin
                  Result:= IntToHex(GUID1.D4[2], 2) + '-' +
                           IntToHex(GUID1.D4[3], 2) + '-' +
                           IntToHex(GUID1.D4[4], 2) + '-' +
                           IntToHex(GUID1.D4[5], 2) + '-' +
                           IntToHex(GUID1.D4[6], 2) + '-' +
                           IntToHex(GUID1.D4[7], 2);
           end;
        end;
    end;
end;

procedure TfrmPrincipal.ApplicationEventsMinimize(Sender: TObject);
begin
    TrayIcon.Visible:= True;
    TrayIcon.ShowBalloonHint;
end;

procedure TfrmPrincipal.TelaChamadosClick(Sender: TObject);
begin
    PopupMenu.Items.Find('Tela Chamados').Enabled:= False;
    frmChamadaFinal:= TfrmChamadaFinal.Create(Self);
    with frmChamadaFinal do begin
         ShowModal;
         FreeAndNil(frmChamadaFinal);
    end;
end;

procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
var
  hora: string;
begin
    hora:= TimeToStr(Time);
    {
    if ScreenCount = 1 then begin
       if frmTelaPedidos <> nil then begin
          frmTelaPedidos.AddStringGrid;
       end;
    end else begin
    }
        with DM do begin
             PedidosLiberadosInsert;
             if frmTelaPesquisa <> nil then begin
                frmTelaPesquisa.RESIZEDBGRID;
             end;

             if (hora = '12:00:00') or (hora = '17:00:00') then begin
                PedidosFaturadosDelete;
             end;
        end;

    //end;
end;

procedure TfrmPrincipal.FecharClick(Sender: TObject);
begin
    Application.Terminate;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
    Caixa:= MacAddress;

    with frmPrincipal do begin
         Hide();
         WindowState:= wsMinimized;
    end;
    AHeight:= Screen.Height;
    LWidth:= Screen.Width;
    ScreenCount:= Screen.MonitorCount;
    
    if ScreenCount = 1 then begin
       PopupMenu.Items.Find('Tela Chamados').Enabled:= False;
       if (Caixa01 = MacAddress) or (Caixa02 = MacAddress) or (Caixa03 = MacAddress) then begin
          PopupMenu.Items.Find('Pedidos Liberados').Enabled:= False;
          PopupMenu.Items.Find('Pedidos Caixa').Enabled:= True;
       end else begin
           PopupMenu.Items.Find('Pedidos Liberados').Enabled:= True;
           PopupMenu.Items.Find('Pedidos Caixa').Enabled:= False;
       end;
    end else begin
        PopupMenu.Items.Find('Tela Chamados').Enabled:= True;
        if (Caixa01 = MacAddress) or (Caixa02 = MacAddress) or (Caixa03 = MacAddress) then begin
           PopupMenu.Items.Find('Pedidos Liberados').Enabled:= False;
           PopupMenu.Items.Find('Pedidos Caixa').Enabled:= True;
        end else begin
            PopupMenu.Items.Find('Pedidos Liberados').Enabled:= True;
            PopupMenu.Items.Find('Pedidos Caixa').Enabled:= False;
        end;
    end;

    with Timer1 do begin
         Enabled:= True;
         Interval:= StrToInt(Timer1Principal);
    end;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
{}
end;

procedure TfrmPrincipal.FormPaint(Sender: TObject);
begin
{}
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
{}
end;

procedure TfrmPrincipal.PedidosLiberados1Click(Sender: TObject);
begin
    PopupMenu.Items.Find('Pedidos Liberados').Enabled:= False;
    frmTelaPesquisa:= TfrmTelaPesquisa.Create(Self);
        with frmTelaPesquisa do begin
         ShowModal;
         MakeFullyVisible(Screen.Monitors[0])
    end;
end;

procedure TfrmPrincipal.VisualizarPedidosClick(Sender: TObject);
begin
    PopupMenu.Items.Find('Pedidos Caixa').Enabled:= False;
    frmTelaPedidos:= TfrmTelaPedidos.Create(Self);
    with frmTelaPedidos do begin
         BringToFront;
         AnimateWindow(frmTelaPedidos.Handle, 1500, AW_VER_NEGATIVE);
         Show;
    end;
end;

end.
