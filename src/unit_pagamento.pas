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
    procedure btn_cancelarClick(Sender: TObject);
    procedure btn_finalizarClick(Sender: TObject);
    procedure SairClick(Sender: TObject);
    procedure btn_pagoClick(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
  private
    procedure atualizar_valor_total;
    procedure atualizar_forma_pagamento;
  public
    procedure abrir_pagamento;
  end;
var
  Form6: TForm6;
implementation
 uses unit_login, unit_carrinho;
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

procedure TForm6.SairClick(Sender: TObject);
begin
  close;
end;

procedure TForm6.btn_pagoClick(Sender: TObject);
begin
  ShowMessage('Confiamos em você! Transação concluida!');
  close;
end;

procedure TForm6.StaticText1Click(Sender: TObject);
begin
  ShowMessage('Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum'
  + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum'
  + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum'
  + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum'
  + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum'
  + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum' + sLineBreak + 'Lorem ipsulum Lorem ipsulum Lorem ipsulum');
end;

procedure TForm6.btn_finalizarClick(Sender: TObject);
begin
  if CheckBox_termos.Checked then
begin
   if ComboBox_pagamentos.Items[ComboBox_pagamentos.ItemIndex] <> 'PIX' then
     begin
        ShowMessage('Apenas Pix está disponível no momento!');
     end
     else
     begin
       Panel_qr_code.Left := (Form6.ClientWidth - Panel_qr_code.Width) div 2;
       Panel_qr_code.Top  := (Form6.ClientHeight - Panel_qr_code.Height) div 2;
       Panel_qr_code.visible := true;
     end;
end
else
begin
  ShowMessage('Você tem que aceitar os termos para continuar!');
end;
end;

procedure TForm6.btn_cancelarClick(Sender: TObject);
begin
   Panel_qr_code.visible := false;
end;

 procedure TForm6.atualizar_valor_total;
 begin
    Form4.Query_valor_total.close;
    Form4.Query_valor_total.ParamByName('user_id').AsInteger := usuario_id;
    Form4.Query_valor_total.open;
    Label_valor_total.Caption := 'R$ ' + Form4.Query_valor_total.FieldByName('total_price').AsString;
    Label_valor_total.Tag :=Form4.Query_valor_total.FieldByName('total_price').AsInteger;

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

   //Pega valor da query carrinho
    atualizar_valor_total;
   //Pega as formas de pagamento do bd
   atualizar_forma_pagamento;



   // o form reabre toda vez pelo carrinho, então limpa os cards anteriores
   while ScrollBox_pagamento.ControlCount > 0 do
     ScrollBox_pagamento.Controls[0].Free;

   linha := 0;
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

     linha := linha + 1;
     Query_itens_pagamento.Next;
   end;


   Query_itens_pagamento.Close;
   Show;
 end;
end.
