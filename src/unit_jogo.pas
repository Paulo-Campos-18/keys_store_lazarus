unit unit_jogo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ZDataset, ZAbstractRODataset, DB;

type

  { TForm2 }

  TForm2 = class(TForm)
    btn_carrinho: TSpeedButton;
    btn_lista_desejo: TSpeedButton;
    btn_mostrar_todos: TSpeedButton;
    btn_mostrar_todos1: TSpeedButton;
    descricao: TLabel;
    image_jogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label_generos: TLabel;
    Label_total_disponivel: TLabel;
    Label_comentarios: TLabel;
    Query_adicionar_wishlist: TZQuery;
    titulo_descricao: TLabel;
    nome: TLabel;
    Panel_area_coments: TPanel;
    preco: TLabel;
    Query_comentarioscomment_text: TZRawCLobField;
    Query_comentarioscreated_at: TZDateTimeField;
    Query_comentariosnickname: TZRawStringField;
    Query_comentariosuser_id: TZIntegerField;
    Query_jogo: TZQuery;
    Query_genres: TZQuery;
    Query_comentarios: TZQuery;
    release_date: TLabel;
    Sair: TSpeedButton;
    box_descricao: TScrollBox;
    box_textodescricao: TScrollBox;
    Query_adicionar_carrinho: TZQuery;
    box_comentarios: TScrollBox;
    studio: TLabel;
    Query_total_keys: TZQuery;
    Query_generos: TZQuery;
    procedure btn_carrinhoClick(Sender: TObject);
    procedure btn_lista_desejoClick(Sender: TObject);
    procedure descricaoClick(Sender: TObject);
    procedure SairClick(Sender: TObject);
    procedure btn_mostrar_todosClick(Sender: TObject);

  private

  public
   procedure CarregarJogo(IdJogo: Integer);
  end;

var
  Form2: TForm2;
  IdJogoAtual: Integer;

implementation
uses unit_login;
{$R *.lfm}

procedure TForm2.SairClick(Sender: TObject);
begin
    while Panel_area_coments.ControlCount > 0 do
    Panel_area_coments.Controls[0].Free;
  Close;
end;

procedure TForm2.btn_carrinhoClick(Sender: TObject);
begin
   if Label_total_disponivel.caption = '0' then
   begin
     ShowMessage('Não há chaves desse jogo no estoque!');
   end
   else
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
      if (Pos('duplicate', LowerCase(E.message)) > 0) or
         (Pos('duplicar', LowerCase(E.message)) > 0) then
        ShowMessage('Você já tem esse jogo no carrinho!')
      else
        ShowMessage('Erro ao adicionar no carrinho, tente mais tarde!');
    end;
  end;
  end;
end;

procedure TForm2.btn_lista_desejoClick(Sender: TObject);
begin
  if not usuario_logado then
   begin
     ShowMessage('É preciso ter feito login para adicionar a lista de desejos!');
   end
   else
   begin

  try
   Query_adicionar_wishlist.close;
   Query_adicionar_wishlist.ParamByName('game_id').AsInteger := IdJogoAtual;
   Query_adicionar_wishlist.ParamByName('user_id').AsInteger := usuario_id;
   Query_adicionar_wishlist.execSQL;
   ShowMessage('Jogo adicionado à lista de desejos!');
  except
     on E: Exception do
     begin
      if (Pos('duplicate', E.message) > 0) then
        ShowMessage('Você já tem esse jogo na lista de desejos!')
      else
        ShowMessage('Erro ao adicionar na lista de desejos, tente mais tarde!');
    end;
  end;
  end;
end;

procedure TForm2.descricaoClick(Sender: TObject);
begin

end;

procedure TForm2.btn_mostrar_todosClick(Sender: TObject);
begin
  Query_comentarios.Close;
  Query_comentarios.ParamByName('game_id').AsInteger := IdJogoAtual;
  Query_comentarios.ParamByName('limit').AsInteger := 9999;
  Query_comentarios.Open;
  CarregarJogo(IdJogoAtual);
  btn_mostrar_todos.Visible := False;
end;


Procedure TForm2.CarregarJogo(IdJogo:Integer);
var
  stream: TMemoryStream;
  linha:integer;
  box_comentario:TPanel;
  user_comentario:TLabel;
  data_comentario: TLabel;
  conteudo_coment: TLabel;

begin
   IdJogoAtual := IdJogo;

   Query_jogo.Close;
   Query_jogo.ParamByName('id').AsInteger := IdJogo;
   Query_jogo.Open;

   Query_comentarios.Close;
   Query_comentarios.ParamByName('game_id').AsInteger := IdJogo;
   Query_comentarios.ParamByName('limit').AsInteger := 4;
   Query_comentarios.Open;

   //Preenchendo labels
   nome.Caption := Query_jogo.FieldByName('name').AsString;
   studio.Caption := 'Estudio: ' + Query_jogo.FieldByName('studio').AsString;
   preco.Caption := 'R$ ' + Query_jogo.FieldByName('price').AsString;
   descricao.Caption := Query_jogo.FieldByName('description').AsString;
   release_date.Caption := 'Data de lançamento: ' + FormatDateTime('dd/mm/yyyy',
   Query_jogo.FieldByName('release_date').AsDateTime);

   //Preenchendo total de keys
   Query_total_keys.Close;
   Query_total_keys.ParamByName('game_id').AsInteger := IdJogo;
   Query_total_keys.Open;

   if Query_total_keys.IsEmpty then
   begin
     Label_total_disponivel.Caption := '0';
     Label_total_disponivel.Font.Color := clWhite;
   end
   else
   begin
     Label_total_disponivel.Caption := Query_total_keys.FieldByName('Total_disponivel').AsString;
     if Query_total_keys.FieldByName('Total_disponivel').AsInteger > 0 then
       Label_total_disponivel.Font.Color := clLime
     else
       Label_total_disponivel.Font.Color := clWhite;
   end;

   Query_total_keys.Close;


   //Preenchendo generos
   Query_generos.Close;
   Query_generos.ParamByName('game_id').AsInteger := IdJogo;
   Query_generos.Open;

   Label_generos.caption := '';
   while not Query_generos.EOF do
    begin
     Label_generos.Caption := Label_generos.Caption + '- ' + Query_generos.FieldByName('name').AsString;
     Query_generos.Next;
     if not Query_generos.EOF then
    Label_generos.Caption := Label_generos.Caption + ', ' + sLineBreak;
    end;

Query_generos.Close;

   try
      stream := TMemoryStream.Create;
      TBlobField(Query_jogo.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image_jogo.Picture.LoadFromStream(stream);
      image_jogo.Stretch := true;
    finally
      stream.Free;
    end;

    //criando blocos para comentários

    while Panel_area_coments.ControlCount > 0 do
    Panel_area_coments.Controls[0].Free;

    linha := 0;
    while not Query_comentarios.EOF do
     begin
      box_comentario := TPanel.Create(self);
      box_comentario.Parent := Panel_area_coments;
      box_comentario.left := 10;
      box_comentario.top := 15 + linha * (250 + 15);
      box_comentario.Width := 450;
      box_comentario.Height := 150;
      box_comentario.color := RGBToColor($20, $20, $20);
      box_comentario.BevelOuter := bvNone;
      box_comentario.BevelInner := bvNone;


    user_comentario := TLabel.Create(self);
    user_comentario.Parent := box_comentario;
    user_comentario.Caption := Query_comentarios.FieldByName('nickname').AsString;
    user_comentario.Width := 250;
    user_comentario.Height := 25;
    user_comentario.top := 10;
    user_comentario.left := 10;
    user_comentario.Font.color := clWhite;
    user_comentario.Font.Name := 'Segoe UI';
    user_comentario.Font.Size := 15;
    user_comentario.Font.Style := [fsBold];

    data_comentario := TLabel.Create(self);
    data_comentario.Parent := box_comentario;
    data_comentario.Caption := FormatDateTime('dd/mm/yyyy',
      Query_comentarios.FieldByName('created_at').AsDateTime);
    data_comentario.Width := 110;
    data_comentario.Height := 20;
    data_comentario.top := 15;
    data_comentario.left := 330;
    data_comentario.Font.color := clSilver;
    data_comentario.Font.Name := 'Segoe UI';
    data_comentario.Font.Size := 10;


    conteudo_coment := TLabel.Create(self);
    conteudo_coment.Parent := box_comentario;
    conteudo_coment.Caption := Query_comentarios.FieldByName('comment_text').AsString;
    conteudo_coment.Width := 430;
    conteudo_coment.Height := 190;
    conteudo_coment.top := 45;
    conteudo_coment.left := 10;
    conteudo_coment.Font.Name := 'Segoe UI';
    conteudo_coment.Font.Size := 10;
    conteudo_coment.Font.Color := clWhite;
    conteudo_coment.WordWrap := True;
    conteudo_coment.AutoSize := False;

      linha := linha + 1;
      Query_comentarios.Next;
     end;

    Panel_area_coments.Height := 15 + linha * (150 + 15);

    btn_mostrar_todos.Parent := Panel_area_coments.Parent;
    btn_mostrar_todos.Left := Panel_area_coments.Left;
    btn_mostrar_todos.Top := Panel_area_coments.Top + Panel_area_coments.Height + 10;
    btn_mostrar_todos.Visible := Query_comentarios.RecordCount >= 4;

end;

end.
