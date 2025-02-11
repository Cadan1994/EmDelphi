﻿{
SPED-CORREÇÃO Versão 2022.11.1.23
+---------------------------------------------------------------------------+
 Tela de processar a correção do  arquivo  txt do  SPED  gerado pelo sistema
 CONSINCO
 Data Criação........: 23/11/2022
 Autor...............: Hilson Santos
+---------------------------------------------------------------------------+
}
unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls, DateUtils, ComObj, Vcl.StdCtrls, Data.DB, Data.Win.ADODB,
  Datasnap.DBClient, MidasLib, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  FireDAC.Phys.PGDef, FireDAC.Phys.PG, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TfPrincipal = class(TForm)
    Image1: TImage;
    ShapeTop: TShape;
    ShapeBotton: TShape;
    ShapeCenter: TShape;
    ADOConn: TADOConnection;
    ADOQuery: TADOQuery;
    ClientDataSet: TClientDataSet;
    FDConn: TFDConnection;
    FDDriverLink: TFDPhysPgDriverLink;
    FDQuery: TFDQuery;
    ShapeLeft: TShape;
    LabelAno: TLabel;
    ComboBoxAno: TComboBox;
    LabelMes: TLabel;
    ComboBoxMes: TComboBox;
    SpeedButton: TSpeedButton;
    LabelProcesso1: TLabel;
    LabelProcesso2: TLabel;
    LabelProcesso3: TLabel;
    ImageProcessando: TImage;
    LabelProcesso4: TLabel;
    OpenDialog: TOpenDialog;
    Panel2: TPanel;
    Button2: TButton;
    Label2: TLabel;
    Label1: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBoxAnoChange(Sender: TObject);
  private
    { Private declarations }
    PerAtual,         { Recebe o período atual }
    PerAnterior,      { Recebe o período anterior }
    DataInicial,      { Recebe a data inicial }
    DataFinal,        { Recebe a data final }
    DAExcel,          { Recebe o caminho do arquivo em excel }
    DASped,           { Recebe o caminho do arquivo em txt do SPED }
    NAExcel,          { Recebe o nome do arquivo em excel com o saldo do estoque em 2019 }
    NASped:           { Recebe o nome do arquivo em txt do SPED a ser corrigido }
    string;
    procedure MovimentacaoAtualProduto;
    procedure InserirDados;
    procedure DeletarDados;
    procedure CorrigindoArquivoSped;
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

const
   Meses: array[1..12] of string = ('Janeiro','Fevereiro','Março','Abril','Maio','Junho','julho','Agosto','Setembro','Outrubro','Novembro','Dezembro');

implementation

uses
  Winapi.ActiveX;

{$R *.dfm}

{ Função que cria a tela de mensagem para o usuário }
function TelaMensagem(
              Botoes: Array of String;
              Mensagem: String = '';
              BtnPadrao: Integer = 1;
              Titulo: String = 'Atenção';
              TipoDlg: TMsgDlgType = mtInformation;
              x: Integer = 0;
              y: Integer = 0
          ): Integer;
var
    Bt: TMsgDlgButtons;           { Recebe o tipo de botão }
    Btxt: Array[3..6] of String;  { Nao foi usado de 1..4 pois o "X" ou ALT+F4 = 2 }
    I,
    C: Integer;
begin
    { Zera var interna ... }
    for I:= 3 to 6 do Btxt[I]:= '';

    { Adiciona captions na var ... }
    for I:= Low(Botoes) to High(Botoes) do Btxt[I + 3]:= Botoes[I];

    Bt:= [];
    { Coloca na BT os botões do tipo mb... }
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
                 { Se for botão ... }
                 if Components[I] is TButton then begin
                    { Caso o modal result dele é o mesmo do que foi criado, muda o caption ... }
                    C:= TButton(Components[I]).ModalResult;
                    if C = mrAll then
                       C:= 6;
                       TButton(Components[I]).Caption:= BTxt[C];

                    { Seta o botão padrão ... }
                    if (BtnPadrao + 2) = TButton(Components[I]).ModalResult then
                       ActiveControl:= TButton(Components[I]);
                 end;
             Result:= ShowModal;
             { Caso pressionado ESC ou X ou ALT+F4 então devolve "0" senão devolve 1 para 1ª botão, 2 para 2ª ... }
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

{ Essa função remove qualquer caracter no texto }
function RemoveCaracteres(const AString, AChars: String): String;
var
    i,
    j,
    k,
    LenString,
    LenChars: Integer;
    PString,
    PChars: PChar;
label
    Ends;
begin
    PString:= Pointer(AString);
    PChars:= Pointer(AChars);
    LenString:= AString.Length;
    LenChars:= AChars.Length;
    k:= 0;
    for i:= 0 to LenString - 1 do begin
      for j:= 0 to LenChars - 1 do
          if PString[i] = PChars[j] then
          Goto Ends;
          PString[k]:= PString[i];
          Inc(k);
          Ends:
    end;
    PString[k]:= #0;
    Result:= StrPas(PString);
end;

{ Essa função transforma a primeira de cada palavra do texto }
function PrimeiraLetraMaiusculaNome(Texto: string): string;
begin
    Result:= '';
    if Trim(Texto) <> '' then
       Result:= UpperCase(Copy(Texto,1,1)) + LowerCase(Copy(Texto,2,Length(Texto)));
end;

{ Essa procedure exclui os registros da tabelas "K100", "K200" e "K990" referente ao período selecionado }
procedure TfPrincipal.DeletarDados;
var
    Data: TDate;
    id,
    QryDeleteK100,
    QryDeleteK200,
    QryDeleteK990: string;
begin
    QryDeleteK100:= 'DELETE FROM sped."K100" WHERE "id" = :Per';
    QryDeleteK200:= 'DELETE FROM sped."K200" WHERE "id" = :Per';
    QryDeleteK990:= 'DELETE FROM sped."K990" WHERE "id" = :Per';

    { Pega a data referente ao ano e mês selecionado }
    Data:= StrToDate('01/'+IntToStr(ComboBoxMes.ItemIndex+1)+'/'+ComboBoxAno.Text);

    { Pega o valor do campo Id das tabelas }
    id:= RemoveCaracteres(Copy(DateToStr(Data), 4, 7), '/');

    with FDConn do begin
         try
             StartTransaction;
             with FDQuery do begin
                  Close;

                  { Limpar os registros da tabela K100 referente período selecionado }
                  with SQL do begin
                       Clear;
                       Add(QryDeleteK100);
                       Params.ParamByName('Per').Value:= id;
                  end;
                  Prepared:= True;
                  ExecSQL;

                  { Limpar os registros da tabela K200 referente período selecionado }
                  with SQL do begin
                       Clear;
                       Add(QryDeleteK200);
                       Params.ParamByName('Per').Value:= id;
                  end;
                  Prepared:= True;
                  ExecSQL;

                  { Limpar os registros da tabela K990 referente período selecionado }
                  with SQL do begin
                       Clear;
                       Add(QryDeleteK990);
                       Params.ParamByName('Per').Value:= id;
                  end;
                  Prepared:= True;
                  ExecSQL;
              end;
              Commit;
              except
                 Rollback;
         end;
    end;
end;

{ Essa procedure inclui os registro apurados nas tabelas "K100", "K200" e "K990" referente ao período selecionado }
procedure TfPrincipal.InserirDados;
var
    id,
    produto,
    dtainicial,
    dtafinal,
    qtdanterior,
    qtdentrada,
    qtdsaida,
    qtdatual,
    QryInsertK100,
    QryInsertK200,
    QryInsertK990: string;
    qtdregistro: Integer;
begin
    qtdregistro:= 0;
    with LabelProcesso1 do begin
         Caption:= 'Processando período anterior';
         Font.Style:= [];
         Left:= 30;
         Top:= SpeedButton.Top + SpeedButton.Height + 20;
         Update;
    end;

    with LabelProcesso2 do begin
         Caption:= 'Processando período atual';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
         Update;
    end;

    with LabelProcesso3 do begin
         Caption:= 'Gravando no banco de dados';
         Font.Style:= [TFontStyle.fsBold];
         Left:= 30;
         Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
         Update;
    end;

    with LabelProcesso4 do begin
         Visible:= True;
         Caption:= 'Criando o arquido do SPED';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
         Update;
    end;

    with ImageProcessando do begin
         Left:= 10;
         Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
         Update;
    end;

    QryInsertK100:= 'INSERT INTO sped."K100"'
                  + '("id","dtainicial","dtafinal")'
                  + 'VALUES'
                  + '(:Per,:Din,:Dfi)';

    QryInsertK200:= 'INSERT INTO sped."K200"'
                  + '("id","produto","dtainicial","dtafinal","qtdanterior","qtdentrada","qtdsaida","qtdatual")'
                  + 'VALUES'
                  + '(:Per,:Pro,:Din,:Dfi,:San,:Qen,:Qsa,:Sat)';

    QryInsertK990:= 'INSERT INTO sped."K990"'
                  + '("id","dtainicial","dtafinal","qtdregistro")'
                  + 'VALUES'
                  + '(:Per,:Din,:Dfi,:Qre)';

    with FDConn do begin
         try
             StartTransaction;
             with FDQuery do begin
                  Close;

                  { Grava os registros na tabela K200 referente período selecionado }
                  with ClientDataSet do begin
                       First;
                       while not Eof do begin
                                 qtdregistro:= qtdregistro + 1;
                                 id:=           FieldByName('Periodo').AsString;
                                 produto:=      FieldByName('Produto').AsString;
                                 dtainicial:=   FieldByName('DataInicial').AsString;
                                 dtafinal:=     FieldByName('DataFinal').AsString;
                                 qtdanterior:=  FieldByName('QSaldoAnterior').AsString;
                                 qtdentrada:=   FieldByName('QEntrada').AsString;
                                 qtdsaida:=     FieldByName('QSaida').AsString;
                                 qtdatual:=     FieldByName('QSaldoAtual').AsString;
                                 with FDQuery do begin
                                      Close;
                                      with SQL do begin
                                           Clear;
                                           Add(QryInsertK200);
                                           with Params do begin
                                                ParamByName('Per').Value:= id;
                                                ParamByName('Pro').Value:= StrToIntDef(produto,0);
                                                ParamByName('Din').Value:= dtainicial;
                                                ParamByName('Dfi').Value:= dtafinal;
                                                ParamByName('San').Value:= StrToIntDef(qtdanterior,0);
                                                ParamByName('Qen').Value:= StrToIntDef(qtdentrada,0);
                                                ParamByName('Qsa').Value:= StrToIntDef(qtdsaida,0);
                                                ParamByName('Sat').Value:= StrToIntDef(qtdatual,0);
                                           end;
                                      end;
                                      Prepared:= True;
                                      ExecSQL;
                                 end;
                                 Next;
                       end;
                  end;

                  { Grava os registros na tabela K100 referente período selecionado }
                  with SQL do begin
                       Clear;
                       Add(QryInsertK100);
                       with Params do begin
                            ParamByName('Per').Value:= id;
                            ParamByName('Din').Value:= dtainicial;
                            ParamByName('Dfi').Value:= dtafinal;
                       end;
                  end;
                  Prepared:= True;
                  ExecSQL;

                  { Grava os registros na tabela K990 referente período selecionado }
                  with SQL do begin
                       Clear;
                       Add(QryInsertK990);
                       with Params do begin
                            ParamByName('Per').Value:= id;
                            ParamByName('Din').Value:= dtainicial;
                            ParamByName('Dfi').Value:= dtafinal;
                            ParamByName('Qre').Value:= qtdregistro + 1;
                       end;
                  end;
                  Prepared:= True;
                  ExecSQL;
             end;
             Commit;
             except
                Rollback;
         end;
    end;
end;

{ Essa procedure gera o arquivo txt do SPED corrigido }
procedure TfPrincipal.CorrigindoArquivoSped;
var
    S,
    R,
    K,
    PerAtual,
    ArqNome,
    ArqLeitura: string;
    I,
    C,
    Q: Integer;
    Lista: TStringList;
    ArqCorrigido: TextFile;
    Data: TDate;
    K200: Boolean;
begin
    I:= 0;
    Q:= 0;
    K200:= False;

    { Pega a data "00/00/0000" referente ao ano e mês selecionado }
    Data:= StrToDate('01/'+IntToStr(ComboBoxMes.ItemIndex+1)+'/'+ComboBoxAno.Text);

    { Pega o período "000000" referente ao ano e mês selecionado }
    PerAtual:= RemoveCaracteres(Copy(DateToStr(Data), 4, 7), '/');

    { Pega o nome do arquivo a ser gerado }
    ArqNome:= 'SPEDCorrigido'+PerAtual;

    { Pega o diretório e o arquivo selecionado doSPED a ser corrigido }
    ArqLeitura:= DASped;

    { Cria o arquivo para receber as informações dos dados do SPED corrigido }
    AssignFile(ArqCorrigido, ExtractFilePath(Application.ExeName) + '\'+ArqNome+'.txt');
    Rewrite(ArqCorrigido);

    with LabelProcesso1 do begin
         Caption:= 'Processando período anterior';
         Font.Style:= [];
         Left:= 30;
         Top:= SpeedButton.Top + SpeedButton.Height + 20;
         Update;
    end;

    with LabelProcesso2 do begin
         Caption:= 'Processando período atual';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
         Update;
    end;

    with LabelProcesso3 do begin
         Caption:= 'Gravando no banco de dados';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
         Update;
    end;

    with LabelProcesso4 do begin
         Visible:= True;
         Caption:= 'Criando o arquido do SPED';
         Font.Style:= [TFontStyle.fsBold];
         Left:= 30;
         Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
         Update;
    end;

    with ImageProcessando do begin
         Left:= 10;
         Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
         Update;
    end;

    { Estância o objeto lista }
    Lista:= TStringList.Create;
    try
        { Verifica se o arquivo do SPED para leitura existe }
        if FileExists(ArqLeitura) then  begin

           { Recebe o arquivo para leitura }
           Lista.LoadFromFile(ArqLeitura);

           { Pega a quantidade de linhas no arquivo }
           C:= Lista.Count;
           while I < C do begin
                 R:= Lista.Strings[I];
                 S:= Copy(Lista.Strings[I], 2, 4);
                 K:= Copy(Lista.Strings[I], 1, 11);
                 with FDQuery do begin
                      Close;
                      if S = 'K100' then begin
                         with SQL do begin
                              Clear;
                              Add('SELECT "dtainicial","dtafinal" FROM sped."K100" WHERE "id" = :id');
                              Params.ParamByName('id').AsString:= PerAtual;
                         end;
                         Prepared:= True;
                         Open;
                         R:= '|K100|'+Fields[0].AsString+'|'+Fields[1].AsString+'|';
                         Writeln(ArqCorrigido, R);
                      end else begin
                          if (S = 'K200') and (K200 = False) then begin
                             K200:= True;
                             with SQL do begin
                                  Clear;
                                  Add('SELECT "dtafinal","produto","qtdatual" FROM sped."K200" WHERE "id" = :id ORDER BY "produto" ASC');
                                  Params.ParamByName('id').AsString:= PerAtual;
                             end;
                             Prepared:= True;
                             Open;
                             while not Eof do begin
                                       Q:= Q + 1;
                                       R:= '|K200|'+Fields[0].AsString+'|'+Fields[1].AsString+'|'+Fields[2].AsString+'|0||';
                                       Writeln(ArqCorrigido, R);
                                       Next;
                             end;
                          end else begin
                              if S = 'K990' then begin
                                 with SQL do begin
                                      Clear;
                                      Add('SELECT "qtdregistro" FROM sped."K990" WHERE "id" = :id');
                                      Params.ParamByName('id').AsString:= PerAtual;
                                 end;
                                 Prepared:= True;
                                 Open;
                                 R:= '|K990|'+Fields[0].AsString+'|';
                                 Writeln(ArqCorrigido, R);
                              end else begin
                                  if K = '|9900|K200|' then begin
                                     R:= '|9900|K200|'+IntToStr(Q)+'|';
                                     Writeln(ArqCorrigido, R);
                                  end else begin
                                      if S <> 'K200' then Writeln(ArqCorrigido, R);
                                  end;
                              end;
                          end;
                      end;
                 end;
                 I:= I + 1;
           end;
        end;
        CloseFile(ArqCorrigido);
        finally
            Lista.DisposeOf;
    end;
end;

{ Essa procedure pega os registro de entrada e saída no banco de dados ORACLE do sistema CONSINCO }
procedure TfPrincipal.MovimentacaoAtualProduto;
var
    Data: TDate;
    QueryDados,
    Tipo,
    Produto: string;
    QAnterior,
    QEAnterior,
    QSAnterior,
    Quantidade,
    QEntrada,
    QSaida: Integer;
begin
    with LabelProcesso1 do begin
         Caption:= 'Processando período anterior';
         Font.Style:= [];
         Left:= 30;
         Top:= SpeedButton.Top + SpeedButton.Height + 20;
         Update;
    end;

    with LabelProcesso2 do begin
         Caption:= 'Processando período atual';
         Font.Style:= [TFontStyle.fsBold];
         Left:= 30;
         Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
         Update;
    end;

    with LabelProcesso3 do begin
         Caption:= 'Gravando no banco de dados';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
         Update;
    end;

    with LabelProcesso4 do begin
         Visible:= True;
         Caption:= 'Criando o arquido do SPED';
         Font.Style:= [];
         Left:= 30;
         Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
         Update;
    end;

    with ImageProcessando do begin
         Left:= 10;
         Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
         Update;
    end;


    Data:= StrToDate('01/'+IntToStr(ComboBoxMes.ItemIndex+1)+'/'+ComboBoxAno.Text);
    DataInicial:= DateToStr(EncodeDate(YearOf(Data), MonthOf(Data), 1));
    DataFinal:= DateToStr(EncodeDate(YearOf(Data),MonthOf(Data),DaysInMonth(Data)));
    PerAtual:= Copy(DateToStr(Data), 4, 7);

    QueryDados:= 'SELECT '
               + 't2.entradasaida Tipo,'
               + 'TO_NUMBER('
               + 'CASE '
               + 'WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743) '
               + 'WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738) '
               + 'ELSE t1.codproduto '
               + 'END)  Codigo,'
               + 'SUM (t1.quantidade) Quantidade '
               + 'FROM implantacao.rf_notaitem t1 '
               + 'INNER JOIN implantacao.rf_notamestre t2 ON t2.seqnota = t1.seqnota AND t2.nroempresa = 1 '
               + 'LEFT JOIN implantacao.map_produto t3 ON t3.seqproduto = t1.codproduto AND TO_CHAR(t3.desccompleta) NOT LIKE ''ZZ%'' '
               + 'WHERE 1=1 '
               + 'AND t2.dtalancamento BETWEEN TO_DATE('''+DataInicial+''',''dd/mm/yyyy'') AND TO_DATE('''+DataFinal+''',''dd/mm/yyyy'') '
               + 'AND t2.dtacancelamento IS NULL '
               + 'AND t1.cfop not in (1923, 2923) '
               + 'GROUP BY t2.entradasaida,'
               + '         TO_NUMBER('
               + '         CASE '
               + '         WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743) '
               + '         WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738) '
               + '         ELSE t1.codproduto '
               + '         END)'
               + 'ORDER BY TO_NUMBER('
               + '         CASE '
               + '         WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743) '
               + '         WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738) '
               + '         ELSE t1.codproduto '
               + '         END) ASC'
               ;
        with ADOQuery do begin
             Close;
             with SQL do begin
                  Clear;
                  Add(QueryDados);
             end;
             Prepared:= True;
             Open;
             First;
             if not IsEmpty then begin
                    with ClientDataSet do begin
                         while not ADOQuery.Eof do begin
                                   QAnterior:= 0;
                                   QEAnterior:= 0;
                                   QSAnterior:= 0;
                                   with ADOQuery do begin
                                        Tipo:= FieldByName('Tipo').Value;
                                        Produto:= FieldByName('Codigo').Value;
                                        Quantidade:= FieldByName('Quantidade').Value;
                                   end;

                                   if Tipo = 'E' then begin
                                      QEntrada:= Quantidade;
                                      QSaida:= 0;
                                   end else begin
                                       QEntrada:= 0;
                                       QSaida:= Quantidade;
                                   end;

                                   if Locate('Produto', Produto, []) then begin
                                      QAnterior:= FieldByName('QSaldoAnterior').Value;
                                      QEAnterior:= FieldByName('QEntrada').Value;
                                      QSAnterior:= FieldByName('QSaida').Value;
                                      Edit;
                                      if Tipo = 'E'
                                      then FieldByName('QEntrada').Value:= QEntrada
                                      else FieldByName('QSaida').Value:= QSaida;
                                   end else begin
                                       Append;
                                       FieldByName('Bloco').Value:=          'K200';
                                       FieldByName('Periodo').Value:=        RemoveCaracteres(PerAtual, '/');
                                       FieldByName('DataInicial').Value:=    RemoveCaracteres(DataInicial, '/');
                                       FieldByName('DataFinal').Value:=      RemoveCaracteres(DataFinal, '/');
                                       FieldByName('Produto').Value:=        Produto;
                                       FieldByName('QSaldoAnterior').Value:= 0;
                                       FieldByName('QEntrada').Value:=       QEntrada;
                                       FieldByName('QSaida').Value:=         QSaida;
                                   end;
                                   FieldByName('QSaldoAtual').Value:=        (QAnterior + QEAnterior + QEntrada) - (QSAnterior + QSaida);
                                   Post;
                                   ADOQuery.Next;
                         end;
                    end;
             end;
        end;
end;

procedure TfPrincipal.Button1Click(Sender: TObject);
begin
    if Sender = Button1 then begin
       DASped:= '';
       NASped:= '';
       if OpenDialog.Execute then begin
          DASped:= OpenDialog.FileName;
          NASped:=  ExtractFileName(Opendialog.FileName);;
          Panel1.Caption:= NASped;
       end;
    end else begin
        DAExcel:= '';
        NAExcel:= '';
        if OpenDialog.Execute then begin
           DAExcel:= OpenDialog.FileName;
           NAExcel:=  ExtractFileName(Opendialog.FileName);;
           Panel2.Caption:= NAExcel;
        end;
    end;
end;

procedure TfPrincipal.ComboBoxAnoChange(Sender: TObject);
begin
    DAExcel:= ExtractFilePath(Application.ExeName);
    NAExcel:=  ExtractFileName(DASped+'SaldoEstoque2019.xlsx');
    NAExcel:= NAExcel;
    if (ComboBoxAno.Text = '2020') and (ComboBoxMes.ItemIndex = 0) then begin
       with Panel2 do begin
            Enabled:= True;
            Caption:= NAExcel;
       end;
    end else begin
        with Panel2 do begin
             Enabled:= False;
             Caption:= '';
        end;
    end;
end;

procedure TfPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
var
    DiretorioDll: string;
begin
    DiretorioDll:= ExtractFilePath(Application.ExeName);
    with fPrincipal do begin
         Caption:= 'SPED-Correção » Versão 2022.11.1.23';
         ClientHeight:= 400;
         ClientWidth:= 700;
    end;
    try
        with ADOConn do begin
             Connected:= False;
             ConnectionString:= 'Provider=OraOLEDB.Oracle;'
                              + 'Data Source=(DESCRIPTION=(CID=GTU_APP)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.168.200)(PORT=1521)))(CONNECT_DATA=(SID=orcl)(SERVER=DEDICATED)));'
                              + 'User Id=hsantos;'
                              + 'Password=H1s@ntos1969;'
                              ;
             LoginPrompt:=False;
             Connected:= True;
        end;

        with FDConn do begin
             DriverName:= 'PG';
             LoginPrompt:= False;
             with Params do begin
                  Database:= 'postgres';
                  UserName:= 'postgres';
                  Password:= 'cfb5ce8c49';
                  Values['DriverID']:= 'PG';
                  Values['MetaDefSchema']:= 'sped';
                  Values['Port']:= '2899';
                  Values['Server']:= '172.16.157.3';
             end;
             FDDriverLink.VendorHome:= DiretorioDll;
             Connected:= True;
        end;

        ADOQuery.Connection:= ADOConn;
        FDQuery.Connection:= FDConn;
        finally
        {}
    end;
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
    ADOConn.Connected:= False;
    FDConn.Connected:= False;
end;

procedure TfPrincipal.FormKeyPress(Sender: TObject; var Key: Char);
begin
//
end;

procedure TfPrincipal.FormPaint(Sender: TObject);
var
   DAtual,
   MAtual,
   AAtual: string;
   I,
   A,
   M,
   AI,
   AF: Integer;
begin
    with LabelAno do begin
         Width:= 75;
         Top:= ShapeTop.Top + ShapeTop.Height;
         Left:= 10;
    end;

    with LabelMes do begin
         Width:= 95;
         Top:= ShapeTop.Top + ShapeTop.Height;
         Left:= LabelAno.Left + LabelAno.Width + 10;
    end;

    with ComboBoxAno do begin
         Width:= LabelAno.Width;
         Left:= LabelAno.Left;
         Top:= LabelAno.Top + LabelAno.Height;
    end;

    with ComboBoxMes do begin
         Width:= LabelMes.Width;
         Left:= LabelMes.Left;
         Top:= LabelMes.Top + LabelMes.Height;
    end;

    with Label1 do begin
         Width:= ShapeLeft.Width - 20;
         Top:= ComboBoxAno.Top + ComboBoxAno.Height + 5;
         Left:= ComboBoxAno.Left;
    end;

    with Panel1 do begin
         Caption:= '';
         Height:= 30;
         Width:= ShapeLeft.Width - 20;
         Left:= Label1.Left;
         Top:= Label1.Top + Label1.Height;
    end;

    with Label2 do begin
         Width:= ShapeLeft.Width - 20;
         Top:= Panel1.Top + Panel1.Height + 5;
         Left:= Panel1.Left;
    end;

    with Panel2 do begin
         Caption:= '';
         Height:= 30;
         Width:= ShapeLeft.Width - 20;
         Left:= Label2.Left;
         Top:= Label2.Top + Label2.Height;
    end;

    with SpeedButton do begin
         Height:= 30;
         Width:= Panel2.Width;
         Left:=  Panel2.Left;
         Top:= Panel2.Top + Panel2.Height + 5;
    end;

    with ShapeCenter do begin
         Brush.Color:= RGB(185,193,197);
         Pen.Color:= RGB(185,193,197);
    end;

    with LabelProcesso1 do begin
         Caption:= '';
         Left:= Panel2.Left;
         Top:= Panel2.Top + Panel2.Height + 20;
    end;

    with LabelProcesso2 do begin
         Caption:= '';
         Left:= SpeedButton.Left;
         Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
    end;

    with LabelProcesso3 do begin
         Caption:= '';
         Left:= SpeedButton.Left;
         Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
    end;

    with LabelProcesso4 do begin
         Caption:= '';
         Left:= SpeedButton.Left;
         Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
    end;

    ImageProcessando.Visible:= False;

    DAtual:= DateToStr(Date);
    AAtual:= FormatDateTime('YYYY', StrToDate(DAtual));
    MAtual:= PrimeiraLetraMaiusculaNome(FormatDateTime('MMMM', StrToDate(DAtual)));
    AI:= StrToInt(AAtual) - 2;
    AF:= StrToInt(AAtual);

    with ComboBoxAno do begin
         with Items do begin
              Clear;
              for A:= AI to AF do
                  Add(IntToStr(A));
         end;
         I:= (AF - AI) + 1;
         DropDownCount:= I;
         ItemIndex:= I - 1;
    end;

    with ComboBoxMes do begin
         with Items do begin
              Clear;
              for M:= 1 to 12 do
                  Add(Meses[M]);
         end;
         DropDownCount:= 12;
         ItemIndex:= StrToInt(FormatDateTime('MM', StrToDate(DAtual)))-1;
    end;


    if (ComboBoxAno.Text = '2020') and (ComboBoxMes.ItemIndex = 0)
    then Panel2.Enabled:= True
    else Panel2.Enabled:= False;

    OnPaint:= nil;
end;

procedure TfPrincipal.FormShow(Sender: TObject);
begin
//
end;

procedure TfPrincipal.SpeedButtonClick(Sender: TObject);
const
  xlDown = -4121;

var
  Data: TDate;
  id,
  Excel,
  Arquivo,
  Planilha,
  Range:            OleVariant;
  Dados:            Variant;
  Path,
  Aba,
  Codigo,
  Quantidade:       string;
  I,
  IndexMes:         Integer;
begin
    Sleep(100);
    if Length(Trim(NASped)) = 0 then begin
       TelaMensagem(['Ok'],'Por favor, selecione o arquivo  do SPED a ser corrigido.');
    end else begin
        if (Length(Trim(NAExcel)) = 0) and (ComboBoxAno.Text = '2020') and (ComboBoxMes.ItemIndex = 0) then begin
           TelaMensagem(['Ok'],'Por favor, selecione o arquivo  do excel com saldo anterior de 2019.');
        end else begin
            ComboBoxAno.Enabled:= False;
            ComboBoxMes.Enabled:= False;
            SpeedButton.Enabled:= False;
            with LabelProcesso1 do begin
                 Caption:= 'Processando período anterior';
                 Font.Style:= [TFontStyle.fsBold];
                 Left:= 30;
                 Top:= SpeedButton.Top + SpeedButton.Height + 20;
                 Update;
            end;

            with LabelProcesso2 do begin
                 Visible:= True;
                 Caption:= 'Processando período atual';
                 Font.Style:= [];
                 Left:= 30;
                 Top:= LabelProcesso1.Top + LabelProcesso1.Height + 5;
                 Update;
            end;

            with LabelProcesso3 do begin
                 Visible:= True;
                 Caption:= 'Gravando no banco de dados';
                 Font.Style:= [];
                 Left:= 30;
                 Top:= LabelProcesso2.Top + LabelProcesso2.Height + 5;
                 Update;
            end;

            with LabelProcesso4 do begin
                 Visible:= True;
                 Caption:= 'Criando o arquido do SPED';
                 Font.Style:= [];
                 Left:= 30;
                 Top:= LabelProcesso3.Top + LabelProcesso3.Height + 5;
                 Update;
            end;

            with ImageProcessando do begin
                 Visible:= True;
                 Left:= 10;
                 Top:= SpeedButton.Top + SpeedButton.Height + 20;
                 Update;
            end;

            IndexMes:= ComboBoxMes.ItemIndex + 1;
            Path:= DAExcel+NAExcel;

            if IndexMes = 1
            then Aba:= Copy(AnsiUpperCase(Meses[12]),1,3)+IntToStr(StrToInt(ComboBoxAno.Text)-1)
            else Aba:= Copy(AnsiUpperCase(Meses[IndexMes]),1,3)+ComboBoxAno.Text;

            Data:= StrToDate('01/'+IntToStr(ComboBoxMes.ItemIndex+1)+'/'+ComboBoxAno.Text);
            DataInicial:= DateToStr(EncodeDate(YearOf(Data), MonthOf(Data), 1));
            DataFinal:= DateToStr(EncodeDate(YearOf(Data),MonthOf(Data),DaysInMonth(Data)));
            PerAtual:= Copy(DateToStr(Data), 4, 7);
            PerAnterior:= Copy(DateToStr(IncMonth(Data,-1)), 4, 7);

            Excel:= CreateOleObject('Excel.Application');
            try
                with ClientDataSet do begin
                     DisableControls;
                     with FieldDefs do begin
                          Clear;
                          Add('Bloco',          ftString,   4, False);
                          Add('Periodo',        ftString,   6, False);
                          Add('DataInicial',    ftString,   8, False);
                          Add('DataFinal',      ftString,   8, False);
                          Add('Produto',        ftString,  10, False);
                          Add('QSaldoAnterior', ftInteger,  0, False);
                          Add('QEntrada',       ftInteger,  0, False);
                          Add('QSaida',         ftInteger,  0, False);
                          Add('QSaldoAtual',    ftInteger,  0, False);
                     end;
                     CreateDataSet;
                     if Aba = 'DEZ2019' then begin
                        Arquivo:= Excel.WorkBooks.Open(Path);
                        Planilha:= Arquivo.WorkSheets.Item[Aba];
                        Range:= Planilha.Range['A2', Planilha.Range['O2'].End[xlDown]];
                        Dados:= Range.Value;
                        for I:= 1 to VarArrayHighBound(Dados, 1) - 1 do begin
                            if Trim(Dados[I, 2]) <> '' then begin
                               Codigo:= Dados[I, 1];
                               Quantidade:= Dados[I, 4];
                               Append;
                               FieldByName('Bloco').AsString:=            'K200';
                               FieldByName('Periodo').AsString:=          RemoveCaracteres(PerAtual, '/');
                               FieldByName('DataInicial').AsString:=      RemoveCaracteres(DataInicial, '/');
                               FieldByName('DataFinal').AsString:=        RemoveCaracteres(DataFinal, '/');
                               FieldByName('Produto').AsString:=          Codigo;
                               FieldByName('QSaldoAnterior').AsInteger:=  StrToIntDef(Quantidade, 0);
                               FieldByName('QEntrada').AsInteger:=        0;
                               FieldByName('QSaida').AsInteger:=          0;
                               FieldByName('QSaldoAtual').AsInteger:=     StrToIntDef(Quantidade, 0);
                               Post;
                             end else begin
                                 Break
                             end;
                        end;
                     end else begin
                         id:= RemoveCaracteres(PerAnterior, '/');
                         with FDQuery do begin
                              Close;
                              with SQL do begin
                                   Clear;
                                   Add('SELECT "produto","qtdatual" FROM sped."K200" WHERE "id" = :id');
                                   Params.ParamByName('id').Value:= id;
                              end;
                              Prepared:= True;
                              Open;
                              if not IsEmpty then begin
                                     First;
                                     while not Eof do begin
                                               Codigo:= Fields[0].AsString;
                                               Quantidade:= Fields[1].AsString;
                                               with ClientDataSet do begin
                                                    Append;
                                                    FieldByName('Bloco').AsString:=            'K200';
                                                    FieldByName('Periodo').AsString:=          RemoveCaracteres(PerAtual, '/');
                                                    FieldByName('DataInicial').AsString:=      RemoveCaracteres(DataInicial, '/');
                                                    FieldByName('DataFinal').AsString:=        RemoveCaracteres(DataFinal, '/');
                                                    FieldByName('Produto').AsString:=          Codigo;
                                                    FieldByName('QSaldoAnterior').AsInteger:=  StrToIntDef(Quantidade,0);
                                                    FieldByName('QEntrada').AsInteger:=        0;
                                                    FieldByName('QSaida').AsInteger:=          0;
                                                    FieldByName('QSaldoAtual').AsInteger:=     StrToIntDef(Quantidade,0);
                                                    Post;
                                               end;
                                               Next;
                                     end;
                              end;
                         end;
                     end;
                     MovimentacaoAtualProduto;
                     First;
                     EnableControls;
                     Open;
                     DeletarDados;
                     InserirDados;
                     CorrigindoArquivoSped;
                     Close;
                     ImageProcessando.Visible:= False;
                     LabelProcesso1.Caption:= '';
                     LabelProcesso2.Caption:= '';
                     LabelProcesso3.Caption:= '';
                     LabelProcesso4.Caption:= '';
                     TelaMensagem(['Ok'], 'Processando realizado com sucesso.', 1, 'Confirmação');
                end;
                finally
                    Range:= Unassigned;
                    Planilha:= Unassigned;
                    Arquivo:= Unassigned;
                    Excel.Quit;
                    Excel:= Unassigned;
            end;
            ComboBoxAno.Enabled:= True;
            ComboBoxMes.Enabled:= True;
            SpeedButton.Enabled:= True;
        end;
    end;
end;

end.
