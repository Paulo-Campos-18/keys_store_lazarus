unit unit_catalogo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, Buttons, ZConnection, ZDataset, ZAbstractRODataset;

type
  { TForm1 }
  TForm1 = class(TForm)
    Image1: TImage;
    ScrollBoxCatalogo: TScrollBox;
    CnnCatalogo: TZConnection;
    QueryCatalogo: TZQuery;
    QueryCatalogoid: TZIntegerField;
    QueryCatalogoimage_byte: TZBlobField;
    QueryCatalogoname: TZRawStringField;
    QueryCatalogoprice: TZFMTBCDField;
    QueryCatalogostudio: TZRawStringField;
    procedure FormCreate(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure CnnCatalogoAfterConnect(Sender: TObject);
  private
    procedure CardClick(Sender: TObject);
  public
  end;

var
  Form1: TForm1;

implementation

uses unit_jogo;

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

procedure TForm1.FormCreate(Sender: TObject);
var
  coluna, linha: integer;
  box: TPanel;
  image: TImage;
  labelNome, labelPreco: TLabel;
  stream: TMemoryStream;
begin

  linha := 0;
  coluna := 0;
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
    box.left := (1 + coluna) * 25 + (coluna * 400);
    box.top := (1 + linha) * 80 + (linha * 350);
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
    labelNome.Font.Size := 15;  //11?
    labelNome.Font.Style := [fsBold];


    labelPreco := TLabel.Create(self);
    labelPreco.Parent := box;
    labelPreco.Caption := 'R$ ' + QueryCatalogo.FieldByName('price').AsString;
    labelPreco.Width := 360;
    labelPreco.Height := 30;
    labelPreco.top := 305;
    labelPreco.left := 20;
    labelPreco.Font.Name := 'Segoe UI';
    labelPreco.Font.Size := 10;
    labelPreco.Font.Color := RGBToColor($6F, $C3, $50);


    coluna := coluna + 1;
    QueryCatalogo.Next;

  end;
  QueryCatalogo.close;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
end;

procedure TForm1.CnnCatalogoAfterConnect(Sender: TObject);
begin
end;

end.
