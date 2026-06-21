unit unit_pagamento;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ZDataset,
  ExtCtrls, Buttons, DB;
type
  { TForm6 }
  TForm6 = class(TForm)
    CheckBox_termos: TCheckBox;
    ComboBox_pagamentos: TComboBox;
    Qr_code: TImage;
    Label1: TLabel;
    Label_nome: TLabel;
    Label_valor_total: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel_qr_code: TPanel;
    Query_itens_pagamento: TZQuery;
    Query_forma_pagamento: TZQuery;
    Query_dados_user: TZQuery;
    Sair: TSpeedButton;
    ScrollBox_pagamento: TScrollBox;
    btn_finalizar: TSpeedButton;
    btn_cancelar: TSpeedButton;
    btn_pago: TSpeedButton;
    StaticText1: TStaticText;
    Query_transacao: TZQuery;
    Query_criar_order: TZQuery;
    Query_alocar_chave: TZQuery;
    Query_vender_chaves: TZQuery;
    Query_limpar_carrinho: TZQuery;
    Query_buscar_order: TZQuery;
    procedure btn_cancelarClick(Sender: TObject);
    procedure btn_finalizarClick(Sender: TObject);
    procedure SairClick(Sender: TObject);
    procedure btn_pagoClick(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private
    FTotal: Currency;
    FOrderId: Integer;
    procedure atualizar_valor_total;
    procedure atualizar_forma_pagamento;
    procedure finalizar_compra;
  public
    procedure abrir_pagamento;
  end;
var
  Form6: TForm6;
implementation
uses unit_catalogo, unit_login, unit_carrinho;
{$R *.lfm}

procedure TForm6.atualizar_forma_pagamento;
var
  nomePag: string;
begin
  ComboBox_pagamentos.Items.Clear;
  Query_forma_pagamento.Close;
  Query_forma_pagamento.Open;
  while not Query_forma_pagamento.EOF do
  begin
    nomePag := Query_forma_pagamento.FieldByName('name').AsString;
    if LowerCase(nomePag) <> 'pix' then
      nomePag := nomePag + ' (Fora de ar)';
    ComboBox_pagamentos.Items.Add(nomePag);
    Query_forma_pagamento.Next;
  end;
  ComboBox_pagamentos.ItemIndex := ComboBox_pagamentos.Items.IndexOf('Pix');
  Query_forma_pagamento.Close;
end;

procedure TForm6.atualizar_valor_total;
begin
  Label_valor_total.Caption := 'R$ ' + FormatFloat('0.00', FTotal);
end;

procedure TForm6.SairClick(Sender: TObject);
begin
  Close;
end;

procedure TForm6.StaticText1Click(Sender: TObject);
begin
  ShowMessage('Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak +
    'Lorem ipsulum Lorem ipsulum Lorem ipsulum');
end;

procedure TForm6.btn_finalizarClick(Sender: TObject);
begin
  if not CheckBox_termos.Checked then
  begin
    ShowMessage('Você tem que aceitar os termos para continuar!');
    Exit;
  end;

  if ComboBox_pagamentos.ItemIndex = -1 then
  begin
    ShowMessage('Selecione uma forma de pagamento!');
    Exit;
  end;

  if LowerCase(ComboBox_pagamentos.Items[ComboBox_pagamentos.ItemIndex]) <> 'pix' then
  begin
    ShowMessage('Apenas Pix está disponível no momento!');
    Exit;
  end;

  Panel_qr_code.Left := (Form6.ClientWidth - Panel_qr_code.Width) div 2;
  Panel_qr_code.Top  := (Form6.ClientHeight - Panel_qr_code.Height) div 2;
  Panel_qr_code.Visible := True;
end;

procedure TForm6.btn_cancelarClick(Sender: TObject);
begin
  Panel_qr_code.Visible := False;
end;

procedure TForm6.btn_pagoClick(Sender: TObject);
begin
  finalizar_compra;
end;

procedure TForm6.finalizar_compra;
var
  paymentMethodId: Integer;
begin
  btn_pago.Enabled := False;

  Query_forma_pagamento.Close;
  Query_forma_pagamento.Open;
  paymentMethodId := 0;
  while not Query_forma_pagamento.EOF do
  begin
    if LowerCase(Query_forma_pagamento.FieldByName('name').AsString) = 'pix' then
    begin
      paymentMethodId := Query_forma_pagamento.FieldByName('id').AsInteger;
      Break;
    end;
    Query_forma_pagamento.Next;
  end;
  Query_forma_pagamento.Close;

  try
    Form1.CnnCatalogo.StartTransaction;
    try
      //cria a order
      Query_criar_order.Close;
      Query_criar_order.ParamByName('user_id').AsInteger := usuario_id;
      Query_criar_order.ExecSQL;

      // pega o id gerado
      Query_buscar_order.Close;
      Query_buscar_order.ParamByName('user_id').AsInteger := usuario_id;
      Query_buscar_order.Open;
      FOrderId := Query_buscar_order.FieldByName('id').AsInteger;
      Query_buscar_order.Close;

      //aloca uma chave por jogo e insere em order_keys
      Query_alocar_chave.Close;
      Query_alocar_chave.ParamByName('order_id').AsInteger := FOrderId;
      Query_alocar_chave.ParamByName('user_id').AsInteger  := usuario_id;
      Query_alocar_chave.ExecSQL;

      // 3) marca as chaves alocadas como vendidas
      Query_vender_chaves.Close;
      Query_vender_chaves.ParamByName('order_id').AsInteger := FOrderId;
      Query_vender_chaves.ExecSQL;

      // 4) registra a transação de pagamento
      Query_transacao.Close;
      Query_transacao.ParamByName('order_id').AsInteger          := FOrderId;
      Query_transacao.ParamByName('payment_method_id').AsInteger := paymentMethodId;
      Query_transacao.ParamByName('total_price').AsCurrency      := FTotal;
      Query_transacao.ExecSQL;

      // 5) limpa o carrinho do usuário
      Query_limpar_carrinho.Close;
      Query_limpar_carrinho.ParamByName('user_id').AsInteger := usuario_id;
      Query_limpar_carrinho.ExecSQL;

      Form1.CnnCatalogo.Commit;
      Panel_qr_code.Visible := False;
      ShowMessage('Compra realizada! Seus jogos já estão na sua biblioteca.');
      Close;

    except
      on E: Exception do
      begin
        Form1.CnnCatalogo.Rollback;
        btn_pago.Enabled := True;
        ShowMessage('Erro ao processar: ' + E.Message);
      end;
    end;

  except
    on E: Exception do
      ShowMessage('Erro de conexão: ' + E.Message);
  end;
end;

procedure TForm6.abrir_pagamento;
var
  linha: integer;
  box: TPanel;
  image: TImage;
  labelNome, labelPreco: TLabel;
  stream: TMemoryStream;
begin
  if not usuario_logado then
  begin
    ShowMessage('É preciso ter feito login para finalizar a compra!');
    Exit;
  end;

  while ScrollBox_pagamento.ControlCount > 0 do
    ScrollBox_pagamento.Controls[0].Free;

  linha := 0;
  FTotal := 0;

  Query_itens_pagamento.Close;
  Query_itens_pagamento.ParamByName('user_id').AsInteger := usuario_id;
  Query_itens_pagamento.Open;

  if Query_itens_pagamento.IsEmpty then
  begin
    ShowMessage('Seu carrinho está vazio!');
    Query_itens_pagamento.Close;
    Exit;
  end;

  while not Query_itens_pagamento.EOF do
  begin
    box := TPanel.Create(self);
    box.Parent := ScrollBox_pagamento;
    box.Left := 20;
    box.Top := 15 + linha * (140 + 15);
    box.Width := 600;
    box.Height := 140;
    box.Color := RGBToColor($20, $20, $20);
    box.BevelOuter := bvNone;
    box.BevelInner := bvNone;
    box.Tag := Query_itens_pagamento.FieldByName('game_id').AsInteger;

    image := TImage.Create(self);
    image.Parent := box;
    image.Top := 10;
    image.Left := 10;
    image.Width := 200;
    image.Height := 120;
    image.Stretch := true;

    try
      stream := TMemoryStream.Create;
      TBlobField(Query_itens_pagamento.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image.Picture.LoadFromStream(stream);
    finally
      stream.Free;
    end;

    labelNome := TLabel.Create(self);
    labelNome.Parent := box;
    labelNome.Caption := Query_itens_pagamento.FieldByName('name').AsString;
    labelNome.Top := 30;
    labelNome.Left := 230;
    labelNome.Font.Color := clWhite;
    labelNome.Font.Name := 'Segoe UI';
    labelNome.Font.Size := 15;
    labelNome.Font.Style := [fsBold];

    labelPreco := TLabel.Create(self);
    labelPreco.Parent := box;
    labelPreco.Caption := 'R$ ' + Query_itens_pagamento.FieldByName('price').AsString;
    labelPreco.Top := 70;
    labelPreco.Left := 230;
    labelPreco.Font.Name := 'Segoe UI';
    labelPreco.Font.Size := 18;
    labelPreco.Font.Color := RGBToColor($6F, $C3, $50);

    FTotal := FTotal + Query_itens_pagamento.FieldByName('price').AsCurrency;

    linha := linha + 1;
    Query_itens_pagamento.Next;
  end;

  Query_itens_pagamento.Close;

  atualizar_valor_total;
  atualizar_forma_pagamento;
  btn_pago.Enabled := True;
  Panel_qr_code.Visible := False;
  Show;
end;

end.
