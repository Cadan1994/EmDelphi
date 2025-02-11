{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Tela de sobre o sistema
 Data Cria��o........: 20/12/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+
}
unit uParametrizacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TListaProcessamentoHora = class(TCollectionItem)
  public
      ProcessamentoId,
      ProcessamentoNome,
      ProcessamentoTempo,
      ProcessamentoStatus: String;
  end;

  TfParametrizacao = class(TForm)
    imgTop: TImage;
    imgIcon: TImage;
    imgFechar: TImage;
    lblTitulo: TLabel;
    StringGrid: TStringGrid;
    imgEditar: TImage;
    imgAtivado: TImage;
    imgDesativado: TImage;
    procedure FormPaint(Sender: TObject);
    procedure imgTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    TGrid,
    frmTamH,
    frmTamW: Integer;
    Query: TFDQuery;
    CampoProcessamentoHora: TListaProcessamentoHora;
    ListaProcessamentoHora: TCollection;
  public
    { Public declarations }
  end;

var
  fParametrizacao: TfParametrizacao;

implementation

{$R *.dfm}

uses uParametrizacaoEdit;

procedure ArredondarComponente(Control: TWinControl);
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

procedure TfParametrizacao.FormCreate(Sender: TObject);
begin
{}
end;

procedure TfParametrizacao.FormPaint(Sender: TObject);
begin
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
         Caption:= 'Parametriza��es';
    end;

    with imgFechar do begin
         Left:= frmTamW - (Width + 25);
         Top:= 5;
    end;

    with StringGrid do begin
         Width:= frmTamW - 10;
         Left:= frmTamW div 2 - (Width div 2);
         Top:= imgTop.Top + imgTop.Height;
         Height:= frmTamH - (imgTop.Height + 5);
    end;

    ArredondarComponente(fParametrizacao);
    ArredondarComponente(StringGrid);

    OnPaint:= nil;
end;

procedure TfParametrizacao.FormShow(Sender: TObject);
var
    I: Integer;
begin
    frmTamH:= ClientHeight;
    frmTamW:= ClientWidth;
    TGrid:= frmTamW - 10;
    with StringGrid do begin
         with Font do begin
              Size:= 10;
              Name:= 'Segoe UI';
              Color:= RGB(028,035,098);
         end;
         ColCount:= 7;
         RowCount:= 2;
         FixedColor:= RGB(028,035,098);
         FixedRows:= 1;
         DefaultRowHeight:= 30;
         ColWidths[00]:= 10;
         ColWidths[01]:= TGrid - 165;
         ColWidths[02]:= 60;
         ColWidths[03]:= 40;
         ColWidths[04]:= 60;
         ColWidths[05]:= 0;
         ColWidths[06]:= 0;
         ListaProcessamentoHora:= TCollection.Create(TListaProcessamentoHora);
         try
             with ListaProcessamentoHora do begin
                  Clear;
                  CampoProcessamentoHora:= TListaProcessamentoHora(Add);
                  with CampoProcessamentoHora do begin
                       ProcessamentoId:= '';
                       ProcessamentoNome:= 'Descri��o';
                       ProcessamentoTempo:= 'Tempo';
                       ProcessamentoStatus:= '';
                       {
                       with fDmBaseDados do begin
                            Query:= TFDQuery.Create(nil);
                            with Query do begin
                                 Connection:= connAplicativo;
                                 Close;
                                 with SQL do begin
                                      Clear;
                                      Add('SELECT "ProcessamentoId","ProcessamentoNome","ProcessamentoTempo", "ProcessamentoStatus" '
                                         +'FROM wscadan."ProcessamentoHora" '
                                         +'WHERE 1=1 '
                                         +'ORDER BY "ProcessamentoNome" ASC'
                                      );
                                      Prepared:= True;
                                      Open;
                                      if not IsEmpty then begin
                                             Enabled:= True;
                                             First;
                                             while not Eof do begin
                                                       with ListaProcessamentoHora do begin
                                                            CampoProcessamentoHora:= TListaProcessamentoHora(Add);
                                                            with CampoProcessamentoHora do begin
                                                                 ProcessamentoId:=     Fields[00].Value;
                                                                 ProcessamentoNome:=   Fields[01].Value;
                                                                 ProcessamentoTempo:=  Fields[02].Value;
                                                                 ProcessamentoStatus:= Fields[03].Value;
                                                            end;
                                                       end;
                                                       Next;
                                             end;
                                      end else begin
                                          with ListaProcessamentoHora do begin
                                               CampoProcessamentoHora:= TListaProcessamentoHora(Add);
                                               with CampoProcessamentoHora do begin
                                                    ProcessamentoId:= '';
                                                    ProcessamentoNome:= '';
                                                    ProcessamentoTempo:= '';
                                                    ProcessamentoStatus:= '';
                                               end;
                                          end;
                                      end;
                                 end;
                                 Close;
                            end;
                       end;
                       }
                       for I:= 0 to Count - 1 do begin
                           RowCount:= Count;
                           with TListaProcessamentoHora(Items[I]) do begin
                                Cells[00,I]:= '';
                                Cells[01,I]:= ProcessamentoNome;
                                Cells[02,I]:= ProcessamentoTempo;
                                if I = 0 then begin
                                   Cells[03,I]:= 'Editar';
                                   Cells[04,I]:= 'Status';
                                end else begin
                                    Cells[03,I]:= '';
                                    Cells[04,I]:= '';
                                end;
                                Cells[05,I]:= ProcessamentoId;
                                Cells[06,I]:= ProcessamentoStatus;
                           end;
                       end;
                  end;
             end;
             finally
                ListaProcessamentoHora.DisposeOf;
                Query.DisposeOf;
         end;
    end;
end;

procedure TfParametrizacao.imgFecharClick(Sender: TObject);
begin
    Close;
end;

procedure TfParametrizacao.imgTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
    sc_DragMove = $f012;
begin
    ReleaseCapture;
    Perform(wm_SysCommand, sc_DragMove, 0);
end;

procedure TfParametrizacao.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    Status: string;
begin
    with StringGrid do begin
         Status:= Trim(Cells[6, ARow]);
         with Canvas do begin
              if ARow = 0 then begin
                 case ACol of
                      1: TextOut(Rect.Left + 5, Rect.Top + ((DefaultRowHeight - TextHeight(Cells[ACol, ARow])) div 2), Cells[ACol, ARow]);
                      2: TextOut(Rect.Left + 5, Rect.Top + ((DefaultRowHeight - TextHeight(Cells[ACol, ARow])) div 2), Cells[ACol, ARow]);
                      3: TextOut(Rect.Left + ((DefaultColWidth - TextWidth(Cells[ACol, ARow])) div 3) + 10, Rect.Top + ((DefaultRowHeight - TextHeight(Cells[ACol, ARow])) div 2), Cells[ACol, ARow]);
                      4: TextOut(Rect.Left + ((DefaultColWidth - TextWidth(Cells[ACol, ARow])) div 3) + 10, Rect.Top + ((DefaultRowHeight - TextHeight(Cells[ACol, ARow])) div 2), Cells[ACol, ARow]);
                 end;
              end else begin
                  case ACol of
                       3: Draw(Rect.Left + ((Rect.Width - imgEditar.Width) div 2) + 2, Rect.Top + ((DefaultRowHeight - imgEditar.Height) div 2), imgEditar.Picture.Graphic);
                       4:
                       begin
                           if    Status = 'S'
                           then  Draw(Rect.Left + ((Rect.Width - imgAtivado.Width) div 3), Rect.Top + ((DefaultRowHeight - imgAtivado.Height) div 2), imgAtivado.Picture.Graphic)
                           else  Draw(Rect.Left + ((Rect.Width - imgDesativado.Width) div 3), Rect.Top + ((DefaultRowHeight - imgDesativado.Height) div 2), imgDesativado.Picture.Graphic);
                       end;
                  end;
              end;
         end;
    end;
end;

procedure TfParametrizacao.StringGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Const
    Coluna = 4;
var
    Cell: TGridCoord;
begin
    with StringGrid do begin
         Cell:= MouseCoord(X, Y);
         if (Cell.X + 1) = Coluna
         then Cursor:= crHandPoint
         else Cursor:= crDefault;
    end;
end;

procedure TfParametrizacao.StringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
    Coluna: Integer;
begin
    Coluna:= ACol;
    if Coluna = 3 then begin
       { Cria o formul�rio manuten��o das query }
       fParametrizacaoEdit:= TfParametrizacaoEdit.Create(Application);
       with fParametrizacaoEdit do begin
            ClientHeight:= 400;
            ClientWidth:= 450;
            Color:= RGB(253,227,153);
            BorderStyle:= bsNone;
            Position:= poScreenCenter;
            ShowModal;
            FreeAndNil(fParametrizacaoEdit);
       end;
    end;
end;

end.
