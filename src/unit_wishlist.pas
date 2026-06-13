unit unit_wishlist;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  DBCtrls, ExtCtrls, ActnList, Menus, ZDataset, ZAbstractRODataset, DB;

type

  { TForm5 }

  TForm5 = class(TForm)
    btn_carrinho: TSpeedButton;
    btn_remover: TSpeedButton;
    buscar_lista: TEdit;
    data_adicionar: TLabel;
    GroupBox1: TScrollBox;
    image_jogo: TImage;
    nome: TLabel;
    Query_adicionar_carrinho: TZQuery;
    query_att_qtd: TZQuery;
    query_att_qtdtotal: TZInt64Field;
    titulo_wishlist: TLabel;
    panel_wishlist: TPanel;
    preco: TLabel;
    qtd_jogo_lista: TLabel;
    query_jogodeleted: TZIntegerField;
    query_jogodescription: TZRawCLobField;
    query_jogoid: TZIntegerField;
    query_jogoimage_byte: TZBlobField;
    query_jogoname: TZRawStringField;
    query_jogoprice: TZFMTBCDField;
    query_jogorelease_date: TZDateTimeField;
    query_jogostudio: TZRawStringField;
    query_wishlistgame_id: TZIntegerField;
    query_wishlistname: TZRawStringField;
    query_wishlistprice: TZFMTBCDField;
    release_date: TLabel;
    query_wishlist: TZQuery;
    Sair: TSpeedButton;
    query_jogo: TZQuery;
    procedure btn_carrinhoClick(Sender: TObject);

  private
    procedure atualizar_qtd_jogos;
  public
    procedure abrir_wishlist;
    procedure CarregarJogo(IdJogo: Integer);
  end;

var
  Form5: TForm5;

implementation

uses unit_catalogo,unit_jogo, unit_login, unit_carrinho;

{$R *.lfm}

procedure TForm5.btn_carrinhoClick(Sender: TObject);
begin
    if not usuario_logado then
     begin
       ShowMessage('É preciso ter feito login para adicionar ao carrinho!');
     end
     else
     begin

    try
     Query_adicionar_carrinho.close;
     Query_adicionar_carrinho.ParamByName('game_id').AsInteger := IdJogoAtual;
     Query_adicionar_carrinho.ParamByName('user_id').AsInteger := usuario_id;
     Query_adicionar_carrinho.execSQL;
     ShowMessage('Jogo adicionado ao carrinho!');
    except
       on E: Exception do
       begin
        if (Pos('duplicate', E.message) > 0) then
          ShowMessage('Você já tem esse jogo no carrinho!')
        else
          ShowMessage('Erro ao adicionar no carrinho, tente mais tarde!');
      end;
    end;
    end;
end;

procedure TForm5.abrir_wishlist;
 begin
   if not usuario_logado then
   begin
     ShowMessage('É preciso ter feito login para acessar a lista de desejos!');
     Exit;
   end;

   try
     Query_wishlist.Close;
     Query_wishlist.ParamByName('user_id').AsInteger := usuario_id;
     Query_wishlist.Open;
     Show;
   except
     on E: Exception do
     ShowMessage('Erro: ' + E.Message);
   end;
 end;
procedure TForm5.atualizar_qtd_jogos;
begin
  query_att_qtd.Close;
  query_att_qtd.ParamByName('user_id').AsInteger := usuario_id;
  query_att_qtd.Open;
  qtd_jogo_lista.Caption := 'Total de jogos na lista: ' + Query_att_qtd.FieldByName('total').AsString;
end;
procedure TForm5.CarregarJogo(IdJogo:Integer);
var
  stream: TMemoryStream;
begin
   IdJogoAtual := IdJogo;

   Query_jogo.Close;
   Query_jogo.ParamByName('id').AsInteger := IdJogo;
   Query_jogo.Open;

   nome.Caption := Query_jogo.FieldByName('name').AsString;
   preco.Caption := 'R$ ' + Query_jogo.FieldByName('price').AsString;
   release_date.Caption := 'Data de lançamento: ' + FormatDateTime('dd/mm/yyyy',
   Query_jogo.FieldByName('release_date').AsDateTime);
   data_adicionar.Caption := 'Adicionado à lista em: ' + FormatDateTime('dd/mm/yyyy',
   Query_wishlist.FieldByName('added_at').AsDateTime);

   try
      stream := TMemoryStream.Create;
      TBlobField(Query_jogo.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image_jogo.Picture.LoadFromStream(stream);
      image_jogo.Stretch := true;
    finally
      stream.Free;
    end;
end;

end.
