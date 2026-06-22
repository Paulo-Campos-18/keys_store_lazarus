unit unit_carrinho;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  Buttons, DBGrids, ExtCtrls, ZDataset, ZAbstractRODataset;

type

  { TForm4 }

  TForm4 = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    GroupBox1: TGroupBox;
    qtd_jogo_carrinho: TLabel;
    Label_valor_total: TLabel;
    Label_nome: TLabel;
    nome1: TLabel;
    Panel1: TPanel;
    query_att_qtd: TZQuery;
    Query_carrinhochaves_disponiveis: TZUInt64Field;
    Query_carrinhogame_id: TZIntegerField;
    Query_remover: TZQuery;
    Query_carrinhoname: TZRawStringField;
    Query_carrinhoname1: TZRawStringField;
    Query_carrinhoprice: TZFMTBCDField;
    Query_carrinhoprice1: TZFMTBCDField;
    btn_remover: TSpeedButton;
    Sair: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Query_carrinho: TZQuery;
    Query_valor_total: TZQuery;
    btn_detalhes: TSpeedButton;
    ZQuery1: TZQuery;
    procedure btn_detalhesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SairClick(Sender: TObject);
    procedure btn_removerClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure atualizar_valor_total;
    procedure atualizar_qtd_jogos;
  public
    procedure abrir_carrinho;
  end;


var
  Form4: TForm4;

implementation
 uses unit_catalogo,unit_jogo, unit_login, unit_wishlist,unit_pagamento;
{$R *.lfm}

{ TForm4 }

procedure TForm4.SairClick(Sender: TObject);
begin
  close;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin

end;

procedure TForm4.btn_detalhesClick(Sender: TObject);
begin
  Form2.CarregarJogo(Query_carrinho.FieldByName('game_id').AsInteger);
  Form2.Show;
end;


procedure TForm4.atualizar_valor_total;
begin
   Query_valor_total.close;
   Query_valor_total.ParamByName('user_id').AsInteger := usuario_id;
   Query_valor_total.open;
   Label_valor_total.Caption := 'R$ ' + Query_valor_total.FieldByName('total_price').AsString;
   Label_valor_total.Tag :=Query_valor_total.FieldByName('total_price').AsInteger;

end;
procedure TForm4.atualizar_qtd_jogos;
begin
  query_att_qtd.Close;
  query_att_qtd.ParamByName('user_id').AsInteger := usuario_id;
  query_att_qtd.Open;
  qtd_jogo_carrinho.Caption := 'Total de jogos no carrinho: ' + Query_att_qtd.FieldByName('total').AsString;
end;

procedure TForm4.btn_removerClick(Sender: TObject);
begin
  if Query_carrinho.IsEmpty then
  begin
    ShowMessage('Nenhum item selecionado!');
    Exit;
  end;

  if MessageDlg('Confirma remoção do item?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      Query_remover.Close;
      Query_remover.ParamByName('user_id').AsInteger := usuario_id;
      Query_remover.ParamByName('game_id').AsInteger := Query_carrinho.FieldByName('game_id').AsInteger;
      Query_remover.ExecSQL;
      Query_carrinho.Close;
      Query_carrinho.ParamByName('user_id').AsInteger := usuario_id;
      Query_carrinho.Open;
      Form4.atualizar_valor_total;
      Form4.atualizar_qtd_jogos
    except
      on E: Exception do
        ShowMessage('Erro ao remover item, contate o suporte!');
    end;
  end;
end;

procedure TForm4.SpeedButton1Click(Sender: TObject);
  var
  temEsgotado: Boolean;
begin
  temEsgotado := False;

  Query_carrinho.First;
  while not Query_carrinho.EOF do
  begin
    if Query_carrinho.FieldByName('chaves_disponiveis').AsInteger = 0 then
    begin
      temEsgotado := True;
      Break;
    end;
    Query_carrinho.Next;
  end;

  if temEsgotado then
  begin
    ShowMessage('Há jogos esgotados no seu carrinho (0 chaves disponíveis). ' +
      'Remova-os para continuar com a compra.');
    Exit;
  end;

  Form6.abrir_pagamento;
end;

 procedure TForm4.abrir_carrinho;
 begin
   if not usuario_logado then
   begin
     ShowMessage('É preciso ter feito login para acessar o carrinho!');
     Exit;
   end;

   try
     Query_carrinho.Close;
     Query_carrinho.ParamByName('user_id').AsInteger := usuario_id;
     Query_carrinho.Open;
     Form4.atualizar_valor_total;
     Form4.atualizar_qtd_jogos;
     Show;
   except
     on E: Exception do
       ShowMessage('Erro: ' + E.Message);
   end;
 end;
end.
