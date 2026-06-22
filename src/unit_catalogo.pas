unit unit_catalogo;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, Buttons, ZConnection, ZDataset, ZAbstractRODataset;

type
  { TForm1 }
  TForm1 = class(TForm)
    Buscar_jogo: TEdit;
    Image1: TImage;
    Image2: TImage;
    PanelTopo: TPanel;
    ScrollBoxCatalogo: TScrollBox;
    CnnCatalogo: TZConnection;
    QueryCatalogo: TZQuery;
    QueryCatalogoid: TZIntegerField;
    QueryCatalogoimage_byte: TZBlobField;
    QueryCatalogoname: TZRawStringField;
    QueryCatalogoprice: TZFMTBCDField;
    btn_carrinho: TSpeedButton;
    btn_Lista_desejos: TSpeedButton;
    btn_inventario: TSpeedButton;
    btn_busca: TSpeedButton;
    procedure btn_carrinhoClick(Sender: TObject);
    procedure btn_inventarioClick(Sender: TObject);
    procedure btn_Lista_desejosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure CnnCatalogoAfterConnect(Sender: TObject);
    procedure btn_buscaClick(Sender: TObject);
  private
    procedure CardClick(Sender: TObject);
    procedure MontarCatalogo;
  public
    procedure avatar_create(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

uses unit_jogo,unit_biblioteca, unit_login, unit_carrinho, unit_wishlist;

{$R *.lfm}

{ TForm1 }

procedure TForm1.CardClick(Sender: TObject);
var
  IdJogoClicado: Integer;
begin
  IdJogoClicado := TControl(Sender).Tag;
  Form2.CarregarJogo(IdJogoClicado);
  Form2.Show;
end;

procedure TForm1.avatar_create(Sender: TObject);
begin
end;

procedure TForm1.MontarCatalogo;
var
  coluna, linha: integer;
  box: TPanel;
  image: TImage;
  labelNome, labelPreco: TLabel;
  stream: TMemoryStream;
begin

  // limpa os cards anteriores
  while ScrollBoxCatalogo.ControlCount > 0 do
    ScrollBoxCatalogo.Controls[0].Free;

  linha := 0;
  coluna := 0;

  QueryCatalogo.Close;
  QueryCatalogo.Open;

  while not QueryCatalogo.EOF do
  begin
    if coluna > 3 then
    begin
      coluna := 0;
      linha := linha + 1;
    end;
    box := TPanel.Create(self);
    box.Parent := ScrollBoxCatalogo;
    box.left := 80 + ((1 + coluna) * 25 + (coluna * 400));
    box.top := 15 + ((1 + linha) * 80 + (linha * 350));
    box.Width := 400;
    box.Height := 350;
    box.color := RGBToColor($20, $20, $20);
    box.BevelOuter := bvNone;
    box.BevelInner := bvNone;
    box.Tag := QueryCatalogo.FieldByName('id').AsInteger;
    box.OnClick := @CardClick;

    image := TImage.Create(self);
    image.Parent := box;
    image.top := 0;
    image.left := 0;
    image.Width := 400;
    image.Height := 250;
    image.Stretch := true;
    image.Tag := QueryCatalogo.FieldByName('id').AsInteger;
    image.OnClick := @CardClick;
    image.Cursor := crHandPoint;

    try
      stream := TMemoryStream.Create;
      TBlobField(QueryCatalogo.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image.Picture.LoadFromStream(stream);
    finally
      stream.Free;
    end;

    labelNome := TLabel.Create(self);
    labelNome.Parent := box;
    labelNome.Caption := QueryCatalogo.FieldByName('name').AsString;
    labelNome.Width := 80;
    labelNome.Height := 30;
    labelNome.top := 270;
    labelNome.left := 20;
    labelNome.Font.color := clWhite;
    labelNome.Font.Name := 'Segoe UI';
    labelNome.Font.Size := 15;
    labelNome.Font.Style := [fsBold];

    labelPreco := TLabel.Create(self);
    labelPreco.Parent := box;
    labelPreco.Caption := 'R$ ' + QueryCatalogo.FieldByName('price').AsString;
    labelPreco.Width := 360;
    labelPreco.Height := 30;
    labelPreco.top := 305;
    labelPreco.left := 20;
    labelPreco.Font.Name := 'Segoe UI';
    labelPreco.Font.Size := 18;
    labelPreco.Font.Color := RGBToColor($6F, $C3, $50);
    coluna := coluna + 1;
    QueryCatalogo.Next;
  end;
  QueryCatalogo.close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //teste
  usuario_logado:= true;
  usuario_id:= 19;

  QueryCatalogo.ParamByName('busca').AsString := '%%';
  MontarCatalogo;
end;

procedure TForm1.btn_carrinhoClick(Sender: TObject);
begin
  Form4.abrir_carrinho;
end;

procedure TForm1.btn_inventarioClick(Sender: TObject);
begin
  Form7.abrir_biblioteca;
end;

procedure TForm1.btn_Lista_desejosClick(Sender: TObject);
begin
  Form5.abrir_wishlist;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  if usuario_logado then
  begin
    ShowMessage('Usuário já fez login!');
    exit;
  end;

  Form3.show;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
end;

procedure TForm1.CnnCatalogoAfterConnect(Sender: TObject);
begin
end;

procedure TForm1.btn_buscaClick(Sender: TObject);
begin
  if Buscar_jogo.Text = '' then
    QueryCatalogo.ParamByName('busca').AsString := '%%'
  else
    QueryCatalogo.ParamByName('busca').AsString := '%' + Buscar_jogo.Text + '%';

  MontarCatalogo;
end;

end.
