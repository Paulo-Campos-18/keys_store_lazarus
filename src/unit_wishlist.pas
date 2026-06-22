unit unit_wishlist;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls, ZDataset, DB;
type
  { TForm5 }
  TForm5 = class(TForm)
    Query_adicionar_carrinho: TZQuery;
    query_att_qtd: TZQuery;
    ScrollBox_wishlist: TScrollBox;
    titulo_wishlist: TLabel;
    qtd_jogo_lista: TLabel;
    query_wishlist: TZQuery;
    Sair: TSpeedButton;
    Query_remover_wishlsit: TZQuery;
    procedure SairClick(Sender: TObject);
  private
    procedure atualizar_qtd_jogos;
    procedure btn_carrinhoClick(Sender: TObject);
    procedure btn_removerClick(Sender: TObject);
  public
    procedure abrir_wishlist;
  end;
var
  Form5: TForm5;
implementation
uses unit_catalogo, unit_login, unit_carrinho;
{$R *.lfm}

procedure TForm5.SairClick(Sender: TObject);
begin
  Close;
end;

procedure TForm5.atualizar_qtd_jogos;
begin
  query_att_qtd.Close;
  query_att_qtd.ParamByName('user_id').AsInteger := usuario_id;
  query_att_qtd.Open;
  qtd_jogo_lista.Caption := 'Total de jogos na lista: ' +
    query_att_qtd.FieldByName('total').AsString;
  query_att_qtd.Close;
end;

procedure TForm5.btn_removerClick(Sender: TObject);
var
  gameId: Integer;
begin
  gameId := TControl(Sender).Tag;

  if MessageDlg('Remover este jogo da lista de desejos?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    Query_remover_wishlsit.Close;
    Query_remover_wishlsit.ParamByName('user_id').AsInteger := usuario_id;
    Query_remover_wishlsit.ParamByName('game_id').AsInteger := gameId;
    Query_remover_wishlsit.ExecSQL;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao remover: ' + E.Message);
      Exit;
    end;
  end;

  ShowMessage('Jogo removido da lista!');
  Close;
  abrir_wishlist;
end;

procedure TForm5.btn_carrinhoClick(Sender: TObject);
var
  gameId: Integer;
begin
  gameId := TControl(Sender).Tag;

  try
    Query_adicionar_carrinho.Close;
    Query_adicionar_carrinho.ParamByName('game_id').AsInteger := gameId;
    Query_adicionar_carrinho.ParamByName('user_id').AsInteger := usuario_id;
    Query_adicionar_carrinho.ExecSQL;
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

procedure TForm5.abrir_wishlist;
var
  linha: integer;
  box: TPanel;
  image: TImage;
  labelNome, labelPreco, labelData, labelAdicionado: TLabel;
  btnCarrinho, btnRemover: TSpeedButton;
  stream: TMemoryStream;
begin
  if not usuario_logado then
  begin
    ShowMessage('É preciso ter feito login para acessar a lista de desejos!');
    Exit;
  end;

  while ScrollBox_wishlist.ControlCount > 0 do
    ScrollBox_wishlist.Controls[0].Free;

  linha := 0;

  query_wishlist.Close;
  query_wishlist.ParamByName('user_id').AsInteger := usuario_id;
  query_wishlist.Open;

  while not query_wishlist.EOF do
  begin
    box := TPanel.Create(self);
    box.Parent := ScrollBox_wishlist;
    box.Left := 10;
    box.Top := 10 + linha * (160 + 10);
    box.Width := ScrollBox_wishlist.ClientWidth - 20;
    box.Height := 160;
    box.Color := RGBToColor($20, $20, $20);
    box.BevelOuter := bvNone;
    box.BevelInner := bvNone;
    box.Tag := query_wishlist.FieldByName('game_id').AsInteger;

    image := TImage.Create(self);
    image.Parent := box;
    image.Left := 10;
    image.Top := 10;
    image.Width := 200;
    image.Height := 140;
    image.Stretch := True;

    try
      stream := TMemoryStream.Create;
      TBlobField(query_wishlist.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image.Picture.LoadFromStream(stream);
    finally
      stream.Free;
    end;

    labelNome := TLabel.Create(self);
    labelNome.Parent := box;
    labelNome.Caption := query_wishlist.FieldByName('name').AsString;
    labelNome.Left := 225;
    labelNome.Top := 15;
    labelNome.Font.Color := clWhite;
    labelNome.Font.Name := 'Segoe UI';
    labelNome.Font.Size := 14;
    labelNome.Font.Style := [fsBold];

    labelPreco := TLabel.Create(self);
    labelPreco.Parent := box;
    labelPreco.Caption := 'R$ ' + query_wishlist.FieldByName('price').AsString;
    labelPreco.Left := 225;
    labelPreco.Top := 50;
    labelPreco.Font.Name := 'Segoe UI';
    labelPreco.Font.Size := 13;
    labelPreco.Font.Color := RGBToColor($6F, $C3, $50);

    labelData := TLabel.Create(self);
    labelData.Parent := box;
    labelData.Caption := 'Lançamento: ' + FormatDateTime('dd/mm/yyyy',
      query_wishlist.FieldByName('release_date').AsDateTime);
    labelData.Left := 225;
    labelData.Top := 80;
    labelData.Font.Color := clSilver;
    labelData.Font.Name := 'Segoe UI';
    labelData.Font.Size := 10;

    labelAdicionado := TLabel.Create(self);
    labelAdicionado.Parent := box;
    labelAdicionado.Caption := 'Adicionado em: ' + FormatDateTime('dd/mm/yyyy',
      query_wishlist.FieldByName('added_at').AsDateTime);
    labelAdicionado.Left := 225;
    labelAdicionado.Top := 100;
    labelAdicionado.Font.Color := clSilver;
    labelAdicionado.Font.Name := 'Segoe UI';
    labelAdicionado.Font.Size := 10;

    btnRemover := TSpeedButton.Create(self);
    btnRemover.Parent := box;
    btnRemover.Caption := 'Remover da lista';
    btnRemover.Left := box.Width - 370;
    btnRemover.Top := 120;
    btnRemover.Width := 170;
    btnRemover.Height := 30;
    btnRemover.Tag := query_wishlist.FieldByName('game_id').AsInteger;
    btnRemover.OnClick := @btn_removerClick;

    btnCarrinho := TSpeedButton.Create(self);
    btnCarrinho.Parent := box;
    btnCarrinho.Caption := 'Adicionar ao carrinho';
    btnCarrinho.Left := box.Width - 190;
    btnCarrinho.Top := 120;
    btnCarrinho.Width := 180;
    btnCarrinho.Height := 30;
    btnCarrinho.Tag := query_wishlist.FieldByName('game_id').AsInteger;
    btnCarrinho.OnClick := @btn_carrinhoClick;

    linha := linha + 1;
    query_wishlist.Next;
  end;

  query_wishlist.Close;
  atualizar_qtd_jogos;
  Show;
end;

end.
