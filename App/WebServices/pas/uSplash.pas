{ WEB SERVICES Versão 2022.11.0001
+---------------------------------------------------------------------------+
 Tela de splash
 Data Criação........: 01/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+}
unit uSplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TfSplash = class(TForm)
    imgWebServer: TImage;
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSplash: TfSplash;

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

procedure TfSplash.FormPaint(Sender: TObject);
begin
    with imgWebServer do begin
         Align:= alClient;
         AutoSize:= True;
    end;
    ArredondarForm(fSplash);
    OnPaint:= nil;
end;

end.
