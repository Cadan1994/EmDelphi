﻿unit UnitChamadaFinal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,Vcl.Imaging.jpeg,
  Vcl.StdCtrls, Vcl.Grids, comOBJ, Data.FMTBcd, Data.SqlExpr, Data.DB, Data.Win.ADODB,
  Vcl.DBGrids, MidasLib, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImage,ShellAPI, System.StrUtils,
  System.DateUtils, Vcl.FileCtrl;

  {Declarações dos Componentes}
type
  TLPedidos = class(TCollectionItem)
  public
      PedidoDados,
      PedidoNumero,
      PedidoNomeCliente,
      PedidoStatus: String;
  end;

  TfrmChamadaFinal = class(TForm)
    Timer01Letreiro: TTimer;
    InfoPanel: TPanel;
    Letreiro: TLabel;
    Timer02Letreiro: TTimer;
    Logo: TImage;
    ImageCollection: TImageCollection;
    ClientePanel: TShape;
    ChamadosPanel: TShape;
    ChamadosLabel: TLabel;
    StringGrid: TStringGrid;
    ClienteLabel: TLabel;
    ClienteQuery: TLabel;
    TimerPropaganda: TTimer;
    imgEmAtendimento: TImage;
    TimerAtualizacaoDados: TTimer;
    VirtualImage: TVirtualImage;
    Timer1: TTimer;
    VirtualImageList: TVirtualImageList;
    procedure FormCreate(Sender: TObject);
    procedure Timer01LetreiroTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer02LetreiroTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure TimerPropagandaTimer(Sender: TObject);
    procedure LogoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    CPedidos: TLPedidos;
    LPedidos: TCollection;
    FFrase: string;
    IFrase: Integer;
    DW: Word;
    DiaSemana: STRING;
    IndexImg,
    QImgDir,
    QImagens: Integer;
    const
    DiasSemana: array[1..7] of string = ('Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado');
    procedure ListarArquivosPath(const Caminho, Extensao: string);
    procedure AddNewImage(const Path, Extension: string);
    procedure ConverterIMG(const Caminho:String);
  public
    { Public declarations }
    procedure RESIZEDBGRID;
    procedure Caixa;
  end;

{Declaração de Variáveis}
var
  frmChamadaFinal: TfrmChamadaFinal;
  nLabel,
  Chamado,
  AlturaScreen,
  LarguraScreen: Integer;
  VarClienteQuery : String;
  VarPedidoQuery : String;
  Cli_Pedido,
  Cx_Pedido: String;

{Inicio de Codificação}
implementation

{$R *.dfm}

uses ConexaoQuery, TelaPrincipal;

function RemoverCarateres(S: string): string;
var
    I:  Integer;
    CaracteresRemover: set of Char;
begin
    Result:= '';

    CaracteresRemover:= ['0'..'9', '.'];

    for I:= Length(S) downto 1 do begin
        if CharInSet(S[I], CaracteresRemover) then
           Delete(S, I, 1)
    end;

    Result:= Trim(S);
end;


function AjustarStr(S: String; T: Integer): String;
begin
    while Length(S) < T do begin
          S:= S+' ';
          if Length(S) < T then begin
             S:= Copy(S, 1, T);
          end;
    end;
    Result:= S;
    S:= '';
end;


function SetScreenResolution(Width, Height: integer): Longint;
var
    DeviceMode: TDeviceMode;
begin
    with DeviceMode do begin
         dmSize:= SizeOf(TDeviceMode);
         dmPelsWidth:= Width;
         dmPelsHeight:= Height;
         dmFields:= DM_PELSWIDTH or DM_PELSHEIGHT;
    end;
    Result:= ChangeDisplaySettings(DeviceMode, CDS_UPDATEREGISTRY);
end;

procedure TfrmChamadaFinal.Caixa;
begin
    with DM do begin
         with FDQuery1 do begin
              with SQL do begin
                   Clear;
                   Add('SELECT DISTINCT "Caixa","RazaoSocial","CodOrdem" '
                      +'FROM cadan."CLICHAMADOS" '
                      +'WHERE 1=1 '
                      +'AND "Status" = ''C'' '
                      +'ORDER BY "CodOrdem" ASC'
                   );
                   Prepared:= True;
                   Open;
                   First;
                   if IsEmpty then begin
                      Cx_Pedido:= IntToStr(0);
                      Cli_Pedido:= '';
                   end else begin
                      Cx_Pedido:= Fields[0].AsString;
                      Cli_Pedido:= RemoverCarateres(Fields[1].AsString);
                      Chamado:= 1;
                   end;
              end;
         end;
         with ClienteQuery do begin
              Caption:= Cli_Pedido;
              AutoSize:= True;
              Align:= alNone;
              Alignment:= taCenter;
              Width:= ClientePanel.Width;
              with Font do begin
                   Size:= 40;
                   Color:= $0000B9FB;
              end;
              Top:= ClienteLabel.Top + (ClienteLabel.Height - 25);
              Left:= LarguraScreen div 2 - (Width div 2);
         end;
    end;
end;

procedure TfrmChamadaFinal.RESIZEDBGRID;
var
    I: integer;
    Sta_Pedido: string;
begin

    with StringGrid do begin
        Top:= ChamadosLabel.Top + ChamadosLabel.Height;
        Left:= ChamadosPanel.Left;
        Height:= ChamadosPanel.Height - (ChamadosLabel.Height + 65);
        Width:= ChamadosPanel.Width;
        with Font do begin
             Size:= 25;
             Name:= 'Segoe UI';
             Color:= RGB(028,035,098);
        end;
        ColCount:= 5;
        RowCount:= 10;
        Selection:= TGridrect(Rect(4,1,4,1));
        DefaultRowHeight:= 50;
        ColWidths[00]:= 40;
        ColWidths[01]:= Width - 40;
        ColWidths[02]:= 0;
        ColWidths[03]:= 0;
        ColWidths[04]:= 0;
        for I := 0 to RowCount -1 do Rows[I].Clear;
        LPedidos:= TCollection.Create(TLPedidos);
        with LPedidos do begin
             Clear;
             with DM do begin
                  with FDQuery1 do begin
                       with SQL do begin
                            Clear;
                            Add('SELECT DISTINCT "RazaoSocial","Status","Caixa","CodOrdem" '
                               +'FROM cadan."CLICHAMADOS" '
                               +'WHERE 1=1 '
                               +'AND "Status" = ''C'' '
                               +'GROUP BY "RazaoSocial","Status","Caixa","CodOrdem" '
                               +'ORDER BY "Status" DESC,"CodOrdem" ASC'
                            );
                            Prepared:= True;
                            Open;
                            if not IsEmpty then begin
                                   Enabled:= True;
                                   First;
                                   Cli_Pedido:= Fields[00].AsString;
                                   Sta_Pedido:= Fields[01].AsString;
                                   while not Eof do begin
                                             with LPedidos do begin
                                                  CPedidos:= TLPedidos(Add);
                                                  with CPedidos do begin
                                                       PedidoNomeCliente:= RemoverCarateres(Fields[00].AsString);
                                                       PedidoStatus:= Fields[01].AsString;
                                                       PedidoDados:= AjustarStr(' ',2)+''+AjustarStr(PedidoNomeCliente,41);
                                                  end;
                                             end;
                                             Next;
                                   end;
                            end else begin
                                with LPedidos do begin
                                     CPedidos:= TLPedidos(Add);
                                     CPedidos.PedidoDados:= '';
                                end;
                            end;
                       end;
                  end;
                  for I:= 0 to Count - 1 do begin
                      RowCount:= Count;
                      with TLPedidos(Items[I]) do begin
                           Cells[00,I]:= '';
                           Cells[01,I]:= PedidoDados;
                           Cells[02,I]:= PedidoNomeCliente;
                           Cells[03,I]:= PedidoStatus;
                      end;
                  end;
             end;
        end;
    end;
end;

procedure TfrmChamadaFinal.ListarArquivosPath(const Caminho, Extensao: string);
var
    DirInfo: TSearchRec;
    I: Integer;
    NImagem,
    NCaminho: string;
begin
    IndexImg:= 0;
    I:= 0;
    if FindFirst(Caminho+Extensao, faAnyFile, DirInfo) = 0 then
        while I = 0 do begin
              NCaminho:= ExtractFilePath(Caminho) + DirInfo.Name;
              NImagem:= Copy(DirInfo.Name, 1, Pos('.',DirInfo.Name) - 1);
              with ImageCollection do begin
                   Add(NImagem, NCaminho);
                   QImagens:= Images.Count;
              end;
              I:= FindNext(DirInfo);
        end;
        FindClose(DirInfo);
end;

procedure TfrmChamadaFinal.AddNewImage(const Path, Extension: string);
var
    DirInfo: TSearchRec;
    I,
    vn_ImgDir: Integer;
    vs_Img,
    Dir: string;
begin
    I:= QImagens;
    vn_ImgDir:= QImgDir;

    if FindFirst(ImgMarket+Extensao, faAnyFile, DirInfo) = 0 then
       while I <= vn_ImgDir do begin
             Dir:= ExtractFilePath(ImgMarket);
             vs_Img:= IntToStr(I)+'.jpeg';
             with ImageCollection do begin
                  Add(vs_Img, Dir);
             end;
             I:= FindNext(DirInfo);
       end;
       FindClose(DirInfo);
end;


procedure TfrmChamadaFinal.LogoClick(Sender: TObject);
begin
    MakeFullyVisible(Screen.Monitors[1]);
end;

procedure TfrmChamadaFinal.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    status: string;
begin
    with StringGrid do begin
         status:= Trim(Cells[03, Arow]);
         with Canvas do begin
              case ACol of
                   0: begin
                          if status = 'C' then
                             Draw(Rect.Left + ((Rect.Width - imgEmAtendimento.Width) div 2), Rect.Top + ((DefaultRowHeight - imgEmAtendimento.Height) div 2), imgEmAtendimento.Picture.Graphic)
                             else
                                Draw(Rect.Left + ((Rect.Width - imgEmAtendimento.Width) div 2), Rect.Top + ((DefaultRowHeight - imgEmAtendimento.Height) div 2), nil);
                      end;
              end;
         end;
    end;
end;

{Como os Componentes ir�o se comportar quando o Programa estiver em funcionamento}
procedure TfrmChamadaFinal.FormClose(Sender: TObject; var Action: TCloseAction);
var
    HTaskbar: HWND;
    OldVal: LongInt;
begin
    HTaskBar := FindWindow('Shell_TrayWnd', nil);
    SystemParametersInfo(97, Word(False), @OldVal, 0);
    EnableWindow(HTaskBar, True);
    ShowWindow(HTaskbar, SW_SHOW);
    with frmPrincipal.PopupMenu.Items do begin
         Find('Tela Chamados').Enabled:= True;
         Find('Pedidos Caixa').Enabled:= False;
    end;
end;

procedure TfrmChamadaFinal.FormCreate(Sender: TObject);
begin
    IFrase:= 0;
    FFrase:= 'CADAN DISTRIBUIÇÃO';

    { Intervalo = 1 }
    with Timer01Letreiro do begin
         Enabled:= True;
         Interval:= strtoint(Timer1Chamada);
    end;

    { Intervalo = 100 }
    with Timer02Letreiro do begin
         Enabled:= False;
         Interval:= strtoint(Timer2Chamada);
    end;

    { Intervalo = 10000 }
    with TimerPropaganda do begin
         Enabled:= True;
         Interval:= strtoint(Timer3Chamada);
    end;

    { Intervalo = 12000 }
    with TimerAtualizacaoDados do begin
         Enabled:= True;
         Interval:= strtoint(Timer4Chamada);
    end;

    { Intervalo = 500 }
    with Timer1 do begin
         Enabled:= True;
         Interval:= strtoint(Timer2Chamada);
    end;

    DW:= DayOfWeek(Now);
    DiaSemana:= DiasSemana[DW];
    Letreiro.Caption:= 'CADAN - NOSSA MISSÃO É SERVIR';
    ClienteLabel.Caption:= 'CLIENTE';
    ChamadosLabel.Caption:= 'CHAMADOS';

end;

{Detreminando a tecla "ESC" com a função de fechar o programa}
procedure TfrmChamadaFinal.FormKeyPress(Sender: TObject; var Key: Char);
begin
   If Key = #27 Then
   Close;
end;

procedure TfrmChamadaFinal.FormShow(Sender: TObject);
var
    Monitor: TMonitor;
begin
    Chamado:= 0;
    Cli_Pedido:= '';
    Cx_Pedido:= IntToStr(0);

    ScreenCount:= Screen.MonitorCount;

    if ScreenCount = 1 then begin
       AlturaScreen:= Screen.Height;
       LarguraScreen:= Screen.Width;
    end else begin
        Monitor:= Screen.Monitors[1];
        Left:= Monitor.Left;
        Top:= Monitor.Top;
        AlturaScreen:= Monitor.Height;
        LarguraScreen:= Monitor.Width;
        ClientHeight:= AlturaScreen;
        ClientWidth:= LarguraScreen;
        MakeFullyVisible(Monitor);
    end;

    with ChamadosPanel do begin
         Align:= alNone;
         BorderStyle:= bsNone;
         WindowState:= TWindowState.wsMaximized;
         KeyPreview := true;
    end;

    with Logo do begin
         Top:= 5;
         Left:= 5;
         Width:= 90;
         Height:= 100;
    end;

    with InfoPanel do begin
         Top:= 5;
         Left:= Logo.Left + Logo.Width + 5;
         Width:= LarguraScreen - InfoPanel.Left - 5;
         Height:= Logo.Height;
         Color:= RGB(251,185,000);
         nLabel:=  (Logo.Left + Logo.Width) + (InfoPanel.Left + InfoPanel.Width);
         begin
             with Letreiro do begin
                  Left:= nLabel;
                  Top:= 0;
                  Font.Size:= 50;
             end;
         end;
    end;

    with ClientePanel do begin
         Top:= Logo.Height + 15;
         Left:= 5;
         Height:= (AlturaScreen div 3) - 60;
         Width:= LarguraScreen - 10;

         with ClienteLabel do begin
              AutoSize:= True;
              Align:= alNone;
              Alignment:= taCenter;
              with Font do begin
                   Size:= 60;
                   Color:= clWhite;
              end;
              Top:= ClientePanel.Top + 5;
              Left:= LarguraScreen div 2 - (Width div 2);
         end;
    end;

    VirtualImageList.ImageCollection:= ImageCollection;

    with VirtualImage do begin
         Top:= ClientePanel.Top + ClientePanel.Height + 5;
         Left:= Logo.Left;
         Height:= AlturaScreen - (Logo.Height + ClientePanel.Height + 25);
         Width:= LarguraScreen div 2;
         ImageCollection:= ImageCollection;
    end;

    ConverterIMG(ImgConvert);
    ListarArquivosPath(ImgMarket,Extensao);

    with ChamadosPanel do begin
         Top:= VirtualImage.Top;
         Left:= VirtualImage.Left + VirtualImage.Width + 5;
         Height:= VirtualImage.Height;
         Width:= LarguraScreen - (VirtualImage.Left + VirtualImage.Width + 10);

         with ChamadosLabel do begin
              Caption:= 'CHAMADOS';
              Align := alNone;
              Alignment:= taCenter;
              with Font do begin
                   Size:= ClienteLabel.Font.Size;
                   Color := clWhite;
              end;
              Top:= ChamadosPanel.Top;
              Left:= ChamadosPanel.Left;
              Width:= ChamadosPanel.Width;
         end;
    end;

    with StringGrid do begin
         Top:= ChamadosLabel.Top + ChamadosLabel.Height;
         Left:= ChamadosPanel.Left;
         Height:= ChamadosPanel.Height - (ChamadosLabel.Height + 65);
         Width:= ChamadosPanel.Width;
         with Font do begin
              Size:= 25;
              Name:= 'Segoe UI';
              Color:= RGB(028,035,098);
         end;
         ColCount:= 5;
         RowCount:= 10;
         Selection:= TGridrect(Rect(4,1,4,1));
         DefaultRowHeight:= 50;
         ColWidths[00]:= 40;
         ColWidths[01]:= Width - 40;
         ColWidths[02]:= 0;
         ColWidths[03]:= 0;
         ColWidths[04]:= 0;
    end;

    Caixa;
    RESIZEDBGRID;

    with ClienteQuery do begin
         Caption:= RemoverCarateres(Cli_Pedido);
         AutoSize:= True;
         Align:= alNone;
         Alignment:= taCenter;
         Width:= ClientePanel.Width;
         with Font do begin
              Size:= 40;
              Color:= $0000B9FB;
         end;
         Top:= ClienteLabel.Top + (ClienteLabel.Height - 10);
         Left:= LarguraScreen div 2 - (Width div 2);
    end;
end;

procedure TfrmChamadaFinal.ConverterIMG(const caminho: string);
var

  DirInfo: TSearchRec;
  A,
  B,
  C: Integer;
  NImagem,
  NCaminho,
  Ext: string;

const
  Mytes: TArray<String> = ['*.jpeg','*.jpg','*.png','*.bmp'];

begin
    try
        for B:= 0 to 3 do begin;
            Ext:= Mytes[B];
            C:= QImagens + 1;
            A:= FindFirst(Caminho+Ext, faAnyFile, DirInfo);

            while A = 0 do begin
                NCaminho:= ExtractFilePath(Caminho) + DirInfo.Name;
                NImagem:= Copy(DirInfo.Name, 1, Pos('.',DirInfo.Name) - 1);

                if Ext = '*.jpeg' then begin
                    try
                        CopyFile(PChar(NCaminho),PChar(ImgMarket+inttostr(C)+'.jpeg'),false);
                        DeleteFile(Ncaminho);
                        except
                            ShowMessage('erro.')
                    end;
                end;

                if Ext = '*.jpg' then begin
                    try
                        var JPEG: TJPEGImage;
                        JPEG:= TJPEGImage.Create;
                        JPEG.CompressionQuality:= 100;
                        JPEG.LoadFromFile(NCaminho);
                        JPEG.SaveToFile(ChangeFilePath(ChangeFileExt(inttostr(C),'.jpeg'),ImgMarket));
                        DeleteFile(Ncaminho)
                        except
                            ShowMessage('erro.')
                    end;
                end;

                if Ext = '*.png' then begin
                    try
                        var JPEG: TPngImage;
                        JPEG:= TPngImage.Create;
                        JPEG.LoadFromFile(NCaminho);
                        JPEG.SaveToFile(ChangeFilePath(ChangeFileExt(inttostr(C),'.jpeg'),ImgMarket));
                        DeleteFile(Ncaminho)
                        except
                            ShowMessage('erro.')
                    end;
                end;

                if Ext = '*.bmp' then begin
                    try
                        var JPEG: TBitmap;
                        JPEG:= TBitmap.Create;
                        JPEG.LoadFromFile(NCaminho);
                        JPEG.SaveToFile(ChangeFilePath(ChangeFileExt(inttostr(C),'.jpeg'),ImgMarket));
                        DeleteFile(Ncaminho)
                        except
                            ShowMessage('erro.')
                    end;
                end;

                A:= FindNext(DirInfo);
                C:= C + 1;
            end;
            FindClose(DirInfo);
        end;
        Except
    end;
end;


procedure TfrmChamadaFinal.Timer01LetreiroTimer(Sender: TObject);
begin
    with Letreiro do begin
         nLabel:= Width + (Left - 1);
         Update;
    end;

    if StrToIntDef(Cx_Pedido, 0) <> 0 then nLabel:= 0;
    if nLabel = 0 then begin
       nLabel:= InfoPanel.Width;
       with Letreiro do begin
            Left:= nLabel;
            if StrToIntDef(Cx_Pedido, 0) <> 0 then
               Caption:= 'COMPAREÇA AO CAIXA '+FormatFloat('00', StrToFloat(Cx_Pedido))
            else
                Caption:= 'CADAN DISTRIBUIÇÃO';
            Align:= alClient;
            Update;
       end;
       Timer01Letreiro.Enabled:= False;
       Timer02Letreiro.Enabled:= True;
    end else begin
        Letreiro.Left:= Letreiro.Left - 1;
    end;

end;

procedure TfrmChamadaFinal.Timer02LetreiroTimer(Sender: TObject);
begin
    IFrase:= IFrase + 1;
    if IFrase = 10 then begin
       IFrase:= 0;
       if StrToIntDef(Cx_Pedido, 0) = 0 then begin
          nLabel:= InfoPanel.Width;
          with Letreiro do begin
               Align:= alNone;
               Left:= nLabel;
               Caption:= 'CADAN - NOSSA MISSÃO É SERVIR';
          end;

          Timer01Letreiro.Enabled:= True;
          Timer02Letreiro.Enabled:= False;
       end else begin
           if Trim(Letreiro.Caption) = '' then begin
              if StrToIntDef(Cx_Pedido, 0) = 0 then begin
                 FFrase:= 'CADAN DISTRIBUIÇÃO'
              end else begin
                  FFrase:= 'COMPAREÇA AO CAIXA '+FormatFloat('00', StrToFloat(Cx_Pedido));
              end;
              Letreiro.Caption:= FFrase;
              Letreiro.Align:= alClient;
           end else begin
              Letreiro.Caption:= '';
           end;
       end;
    end;
end;

procedure TfrmChamadaFinal.Timer1Timer(Sender: TObject);
begin
    Caixa;
    RESIZEDBGRID;
end;

procedure TfrmChamadaFinal.TimerPropagandaTimer(Sender: TObject);
var
    DirInfo: TSearchRec;
begin
    with VirtualImage do begin
         if IndexImg < QImagens then begin
            QImgDir:= 0;
            ImageIndex:= IndexImg;
            IndexImg:= IndexImg + 1;
            if FindFirst(ImgMarket+Extensao, faAnyFile, DirInfo) = 0 then begin
                try
                    repeat
                    Inc(QImgDir);
                    until FindNext(DirInfo) <> 0;
                    finally
                        FindClose(DirInfo);
                end;
            end;
            if QImagens < QImgDir then
               AddNewImage(ImgMarket, Extensao);
         end else begin
              ConverterIMG(ImgConvert);
              ListarArquivosPath(ImgMarket,Extensao);
              IndexImg:= 0;
         end;
    end;

end;

end.
