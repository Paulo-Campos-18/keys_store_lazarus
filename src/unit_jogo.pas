unit unit_jogo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ZDataset, DB;

type

  { TForm2 }

  TForm2 = class(TForm)
    image_jogo: TImage;
    nome: TLabel;
    preco: TLabel;
    descricao: TLabel;
    btn_lista_desejo: TSpeedButton;
    btn_carrinho: TSpeedButton;
    studio: TLabel;
    release_date: TLabel;
    Label6: TLabel;
    Sair: TSpeedButton;
    Query_jogo: TZQuery;
    procedure SairClick(Sender: TObject);
  private

  public
   procedure CarregarJogo(IdJogo: Integer);
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

procedure TForm2.SairClick(Sender: TObject);
begin
  Close;
end;

Procedure TForm2.CarregarJogo(IdJogo:Integer);
var
  stream: TMemoryStream;
begin
   Query_jogo.Close;
   Query_jogo.ParamByName('id').AsInteger := IdJogo;
   Query_jogo.Open;

   nome.Caption := Query_jogo.FieldByName('name').AsString;
   studio.Caption := Query_jogo.FieldByName('studio').AsString;
   preco.Caption := 'R$ ' + Query_jogo.FieldByName('price').AsString;
   studio.Caption := Query_jogo.FieldByName('studio').AsString;
   descricao.Caption := Query_jogo.FieldByName('description').AsString;
   release_date.Caption := FormatDateTime('dd/mm/yyyy',
   Query_jogo.FieldByName('release_date').AsDateTime);


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

