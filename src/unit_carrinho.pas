unit unit_carrinho;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  Buttons, DBGrids, ZDataset, ZAbstractRODataset;

type

  { TForm4 }

  TForm4 = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    GroupBox1: TGroupBox;
    Query_carrinhogame_id: TZIntegerField;
    Query_remover: TZQuery;
    Query_carrinhoname: TZRawStringField;
    Query_carrinhoname1: TZRawStringField;
    Query_carrinhoprice: TZFMTBCDField;
    Query_carrinhoprice1: TZFMTBCDField;
    Sair: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Query_carrinho: TZQuery;
    Query_valor_total: TZQuery;
    procedure SairClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private

  public
    procedure abrir_carrinho;
  end;

var
  Form4: TForm4;

implementation
 uses unit_catalogo,unit_jogo, unit_login;
{$R *.lfm}

{ TForm4 }

procedure TForm4.SairClick(Sender: TObject);
begin
  close;
end;


procedure TForm4.SpeedButton1Click(Sender: TObject);
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
    except
      on E: Exception do
        ShowMessage('Erro ao remover item, contate o suporte!');
    end;
  end;
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
     Show;
   except
     on E: Exception do
       ShowMessage('Erro: ' + E.Message);
   end;
 end;

end.

