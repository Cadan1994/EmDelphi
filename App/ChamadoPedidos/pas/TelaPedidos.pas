unit TelaPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.Imaging.pngimage, Vcl.Buttons, Data.DB, Vcl.StdCtrls, System.UITypes;

type
  TLPedidos = class(TCollectionItem)
  public
      PedidoDados,
      PedidoNomeCliente,
      PedidoStatus,
      PedidoFormaPagto,
      PedidoMac: String;
  end;

  TfrmTelaPedidos = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    StringGrid: TStringGrid;
    Label1: TLabel;
    Panel2: TPanel;
    btnLiberar: TSpeedButton;
    btnCharmar: TSpeedButton;
    Image2: TImage;
    imgEmAtendimento: TImage;
    imgBoleto: TImage;
    imgCheque: TImage;
    ImgDinheiro: TImage;
    imgCartao: TImage;
    Shape1: TShape;
    Shape2: TShape;
    Timer1: TTimer;
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure btnCharmarClick(Sender: TObject);
    procedure btnLiberarClick(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    CPedidos: TLPedidos;
    LPedidos: TCollection;
    Status,
    Mac: string;
    AReg: Integer;
  public
    { Public declarations }
    Procedure AddStringGrid;
  end;

var
  frmTelaPedidos: TfrmTelaPedidos;

implementation

{$R *.dfm}

uses ConexaoQuery, TelaPrincipal, UnitChamadaFinal;

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

function GetTaskbarHeight: Integer;
var
    TaskbarHandle: HWND;
    TaskbarRect: TRect;
begin
    TaskbarHandle := FindWindow('Shell_TrayWnd', nil);
    if TaskbarHandle <> 0 then begin
        GetWindowRect(TaskbarHandle, TaskbarRect);
        Result := TaskbarRect.Bottom - TaskbarRect.Top;
    end else
        Result := 0;
end;


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

procedure TfrmTelaPedidos.AddStringGrid;
var
  I: integer;
begin
    btnCharmar.Enabled:= False;
    btnLiberar.Enabled:= False;
    with StringGrid do begin
         Visible:= False;
         with Font do begin
              Size:= 15;
              Style:= [TFontStyle.fsBold];
         end;
         ColCount:= 6;
         RowCount:= 1;
         DefaultRowHeight:= Height div 10;
         ColWidths[00]:= Height div 10;
         ColWidths[01]:= Height div 10;
         ColWidths[02]:= Width - (Height div 10);
         ColWidths[03]:= 0;
         ColWidths[04]:= 0;
         ColWidths[05]:= 0;
         for I := 0 to RowCount -1 do Rows[I].Clear;
         LPedidos:= TCollection.Create(TLPedidos);
         with LPedidos do begin
              Clear;
              with DM do begin
                   with FDQuery1 do begin
                        with SQL do begin
                             Clear;
                             add('SELECT "RazaoSocial","Status","FormaPagto","Mac","CodOrdem" '
                                +'FROM cadan."CLICHAMADOS" '
                                +'WHERE 1=1 '
                                +'AND "Status" IN (''A'',''C'') '
                                +'GROUP BY "RazaoSocial","Status","FormaPagto","Mac","CodOrdem" '
                                +'ORDER BY "Status" DESC,"CodOrdem" ASC'
                             );
                             Prepared:= True;
                             Open;
                             if not IsEmpty then begin
                                    btnCharmar.Enabled:= True;
                                    btnLiberar.Enabled:= True;
                                    Visible:= True;
                                    First;
                                    while not Eof do begin
                                              with LPedidos do begin
                                                   CPedidos:= TLPedidos(Add);
                                                   with CPedidos do begin
                                                        PedidoNomeCliente:= RemoverCarateres(Fields[00].AsString);
                                                        PedidoStatus:= Fields[01].AsString;
                                                        PedidoFormaPagto:= Fields[02].AsString;
                                                        PedidoMac:= Fields[03].AsString;
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
                             Close;
                        end;
                   end;
               end;
               for I:= 0 to Count - 1 do begin
                   RowCount:= Count;
                   with TLPedidos(Items[I]) do begin
                        Cells[00,I]:= '';
                        Cells[01,I]:= '';
                        Cells[02,I]:= PedidoDados;
                        Cells[03,I]:= PedidoNomeCliente;
                        Cells[04,I]:= PedidoFormaPagto;
                        Cells[05,I]:= PedidoStatus;
                        Cells[06,I]:= PedidoMac;
                   end;
               end;
         end;
         //Row:= AReg;
    end;
end;

procedure TfrmTelaPedidos.btnCharmarClick(Sender: TObject);
begin
    Resposta:= 'N';
    with StringGrid do begin
         AReg:= Row;
         NomeClienteSelect:= Trim(Cells[03, AReg]);
         Fmpagto:= Trim(Cells[04, AReg]);
         Status:= Trim(Cells[05, AReg]);
         CodMac:= Trim(Cells[06, AReg]);
    end;
    Operacao:= 1;

    with DM do begin
         with FDQuery1 do begin
              with SQL do begin
                   Clear;
                   add('SELECT "RazaoSocial", "Status", "FormaPagto" '
                      +'FROM cadan."CLICHAMADOS" '
                      +'WHERE 1=1 '
                      +'AND "Mac" = '''+Caixa+''''
                   );
                   Prepared:= True;
                   Open;
                   if IsEmpty then begin
                      StaMemory:= '';
                   end else begin
                       Resposta:= 'S';
                       CodMemory:= Fields[0].AsString;
                       StaMemory:= Fields[1].AsString;
                       FpgMemory:= Fields[2].AsString;
                   end;
              end;
         end;
    end;

    if Status = 'C' then begin
       ShowMessage('Cliente j� no caixa.');
    end else begin
        if StaMemory = 'C' then begin
           if MessageDlg('Deseja realmente chamar o pr�ximo cliente?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then begin
              DM.ChamarClientePagamento;
           end;
        end else begin
            DM.ChamarClientePagamento;
        end;
    end;
    AddStringGrid;
    Timer1.Enabled:= True;
end;

procedure TfrmTelaPedidos.btnLiberarClick(Sender: TObject);
begin
    Operacao:= 2;
    AReg:= StringGrid.Row;
    with StringGrid do begin
         NomeClienteSelect:= Trim(Cells[03, AReg]);
         Fmpagto:= Trim(Cells[04, AReg]);
         StatusSelect:= Cells[05, AReg];
         CodMac:= Trim(Cells[06, AReg]);
    end;
    if Caixa = CodMac then begin
       if StatusSelect = 'A' then begin
          ShowMessage('Cliente n�o foi chamado.');
       end else begin
           DM.ChamarClientePagamento;
       end;
    end else begin
        ShowMessage('Aten��o! Voc� n�o chamou esse cliente.');
    end;
    AddStringGrid;
    Timer1.Enabled:= True;
end;

procedure TfrmTelaPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    frmPrincipal.PopupMenu.Items.Find('Pedidos Caixa').Enabled:= True;
end;

procedure TfrmTelaPedidos.FormCreate(Sender: TObject);
var
    TaskbarHeight: Integer;
begin
    TaskbarHeight := GetTaskbarHeight;
    ClientWidth:= 600;
    Left:= LWidth - ClientWidth;
    Top:= AHeight - (ClientHeight + TaskbarHeight);
    Panel2.Width:= ClientWidth;
    btnCharmar.Width:= Panel2.Width div 2;
    btnLiberar.Width:= Panel2.Width div 2;
    KeyPreview:= True;
    with Timer1 do begin
         Enabled:= True;
         Interval:= StrToInt(Timer1Pedidos);
    end;

end;

procedure TfrmTelaPedidos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    frmTelaPedidos.Close
  end;
end;

procedure TfrmTelaPedidos.FormShow(Sender: TObject);
begin
    AddStringGrid;
end;

procedure TfrmTelaPedidos.Image2Click(Sender: TObject);
begin
    Close;
    frmPrincipal.PopupMenu.Items.Find('Pedidos Caixa').Enabled:= True;
end;

procedure TfrmTelaPedidos.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    FormaPagto: string;
begin
    with StringGrid do begin
         FormaPagto:= Trim(Cells[04, Arow]);
         with Canvas do begin
              if gdSelected in State then
                 AReg:= Row;
                 Cursor:= crHandPoint;
                 NomeClienteSelect:= Trim(Cells[03, Arow]);
                 Status:= Trim(Cells[05, Arow]);
                 Mac:= Trim(Cells[06, Arow]);
                 case ACol of
                   0: begin
                          if PrimeiroNome(FormaPagto) = 'Dinheiro' then begin
                             Draw(Rect.Left + ((Rect.Width - ImgDinheiro.Width) div 2), Rect.Top + ((DefaultRowHeight - ImgDinheiro.Height) div 2), ImgDinheiro.Picture.Graphic)
                          end else begin
                          if PrimeiroNome(FormaPagto) = 'Boleto' then begin
                             Draw(Rect.Left + ((Rect.Width - imgBoleto.Width) div 2), Rect.Top + ((DefaultRowHeight - imgBoleto.Height) div 2), imgBoleto.Picture.Graphic)
                          end else begin
                          if PrimeiroNome(FormaPagto) = 'Cheque' then begin
                             Draw(Rect.Left + ((Rect.Width - imgCheque.Width) div 2), Rect.Top + ((DefaultRowHeight - imgCheque.Height) div 2), imgCheque.Picture.Graphic)
                          end else begin
                          if PrimeiroNome(FormaPagto) = 'Cartao' then begin
                             Draw(Rect.Left + ((Rect.Width - imgCartao.Width) div 2), Rect.Top + ((DefaultRowHeight - imgCartao.Height) div 2), imgCartao.Picture.Graphic)
                          end else begin
                              Draw(Rect.Left + ((Rect.Width - ImgDinheiro.Width) div 2), Rect.Top + ((DefaultRowHeight - ImgDinheiro.Height) div 2), nil);
                          end;
                          end;
                          end;
                          end;
                      end;
                   1: begin
                          if status = 'C' then
                             Draw(Rect.Left + ((Rect.Width - imgEmAtendimento.Width) div 2), Rect.Top + ((DefaultRowHeight - imgEmAtendimento.Height) div 2), imgEmAtendimento.Picture.Graphic)
                             else
                                Draw(Rect.Left + ((Rect.Width - imgEmAtendimento.Width) div 2), Rect.Top + ((DefaultRowHeight - imgEmAtendimento.Height) div 2), nil);
                      end;
                  end;
         end;
    end;
end;

procedure TfrmTelaPedidos.Timer1Timer(Sender: TObject);
begin
    AddStringGrid;
end;

end.
