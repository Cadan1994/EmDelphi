{ WEB SERVICES Vers�o 2022.11.0001
+---------------------------------------------------------------------------+
 Tela de sobre o sistema
 Data Cria��o........: 01/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uSobre;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfSobre = class(TForm)
    imgTop: TImage;
    imgIcon: TImage;
    imgFechar: TImage;
    lblTitulo: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    procedure FormPaint(Sender: TObject);
    procedure imgTopMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgFecharClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSobre: TfSobre;

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

procedure TfSobre.FormPaint(Sender: TObject);
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

    with Label1 do begin
         Caption:= 'Cadan� Web Services Vers�o 2022.11.0001';
         Top:= imgTop.Top + imgTop.Height + 10;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 14;
         end;
    end;

    with Label2 do begin
         Caption:= 'Copyright � 2022 Cadan Distribui��o, Todos os direitos reservados';
         Top:= Label1.Top + Label1.Height + 5;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 10;
         end;
    end;

    with Label3 do begin
         Caption:= 'IDE de desenvolvimento';
         Top:= Label2.Top + Label2.Height + 10;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 14;
         end;
    end;

    with Label4 do begin
         Caption:= 'Delphi 10.4 Community Edition';
         Top:= Label3.Top + Label3.Height;
         with Font do begin
              Name:= 'Calibri';
              Style:= [];
              Size:= 12;
         end;
    end;

    with Label5 do begin
         Caption:= 'Banco de Dados Envolvidos';
         Top:= Label4.Top + Label4.Height + 10;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 14;
         end;
    end;

    with Label6 do begin
         Caption:= 'Oracle Database 11g Release 11.2.0.4.0';
         Top:= Label5.Top + Label5.Height;
         with Font do begin
              Name:= 'Calibri';
              Style:= [];
              Size:= 12;
         end;
    end;

    with Label7 do begin
         Caption:= 'PostgreSQL 14 Released';
         Top:= Label6.Top + Label6.Height;
         with Font do begin
              Name:= 'Calibri';
              Style:= [];
              Size:= 12;
         end;
    end;

    with Label8 do begin
         Caption:= 'Desenvolvedor';
         Top:= Label7.Top + Label7.Height + 10;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 14;
         end;
    end;

    with Label9 do begin
         Caption:= 'Hilson Santos';
         Top:= Label8.Top + Label8.Height;
         with Font do begin
              Name:= 'Calibri';
              Style:= [];
              Size:= 12;
         end;
    end;

    with Label10 do begin
         Caption:= 'Setor';
         Top:= Label9.Top + Label9.Height + 10;
         with Font do begin
              Name:= 'Calibri';
              Style:= [TFontStyle.fsBold];
              Size:= 14;
         end;
    end;

    with Label11 do begin
         Caption:= 'Tecnol�gia da Informa��o';
         Top:= Label10.Top + Label10.Height;
         with Font do begin
              Name:= 'Calibri';
              Style:= [];
              Size:= 12;
         end;
    end;

    Label1.Left:= frmTamW div 2 - (Label1.Width div 2);
    Label2.Left:= frmTamW div 2 - (Label2.Width div 2);
    Label3.Left:= frmTamW div 2 - (Label3.Width div 2);
    Label4.Left:= frmTamW div 2 - (Label4.Width div 2);
    Label5.Left:= frmTamW div 2 - (Label5.Width div 2);
    Label6.Left:= frmTamW div 2 - (Label6.Width div 2);
    Label7.Left:= frmTamW div 2 - (Label7.Width div 2);
    Label8.Left:= frmTamW div 2 - (Label8.Width div 2);
    Label9.Left:= frmTamW div 2 - (Label9.Width div 2);
    Label10.Left:= frmTamW div 2 - (Label10.Width div 2);
    Label11.Left:= frmTamW div 2 - (Label11.Width div 2);

    fSobre.ClientHeight:= Label11.Top + Label11.Height + 20;

    ArredondarForm(fSobre);

    OnPaint:= nil;
end;

procedure TfSobre.imgFecharClick(Sender: TObject);
begin
    Close;
end;

procedure TfSobre.imgTopMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
    sc_DragMove = $f012;
begin
    ReleaseCapture;
    Perform(wm_SysCommand, sc_DragMove, 0);
end;

end.
