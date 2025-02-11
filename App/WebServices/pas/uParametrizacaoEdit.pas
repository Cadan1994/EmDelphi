{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Tela de sobre o sistema
 Data Cria��o........: 00/00/0000
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uParametrizacaoEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfParametrizacaoEdit = class(TForm)
    imgTop: TImage;
    imgIcon: TImage;
    imgFechar: TImage;
    lblTitulo: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure imgTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgFecharClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fParametrizacaoEdit: TfParametrizacaoEdit;

implementation

{$R *.dfm}

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

procedure TfParametrizacaoEdit.FormPaint(Sender: TObject);
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
         Caption:= 'Parametriza��o Editar';
    end;

    with imgFechar do begin
         Left:= frmTamW - (Width + 25);
         Top:= 5;
    end;

    ArredondarForm(fParametrizacaoEdit);

    OnPaint:= nil;
end;

procedure TfParametrizacaoEdit.imgFecharClick(Sender: TObject);
begin
    Close;
end;

procedure TfParametrizacaoEdit.imgTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
    sc_DragMove = $f012;
begin
    ReleaseCapture;
    Perform(wm_SysCommand, sc_DragMove, 0);
end;

end.
