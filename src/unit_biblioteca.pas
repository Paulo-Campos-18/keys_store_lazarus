unit unit_biblioteca;
{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls, ZDataset, DB, Clipbrd;
type
  { TForm7 }
  TForm7 = class(TForm)
    Edit_chave: TEdit;
    Label1: TLabel;
    Panel_chave: TPanel;
    Query_biblioteca: TZQuery;
    Query_chave: TZQuery;
    ScrollBox_biblioteca: TScrollBox;
    btn_sair: TSpeedButton;
    SpeedButton1: TSpeedButton;
    procedure SairClick(Sender: TObject);
    procedure btn_sairClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure CardClick(Sender: TObject);
  public
    procedure abrir_biblioteca;
  end;
var
  Form7: TForm7;
implementation
uses unit_login;
{$R *.lfm}

procedure TForm7.SairClick(Sender: TObject);
begin
  Close;
end;

procedure TForm7.btn_sairClick(Sender: TObject);
begin
  Panel_chave.Visible := False;
end;

procedure TForm7.SpeedButton1Click(Sender: TObject);
begin
  close;
end;

procedure TForm7.CardClick(Sender: TObject);
var
  gameId: Integer;
begin
  gameId := TControl(Sender).Tag;

  if QuestionDlg('Confirmação', 'Tem certeza que quer revelar o código de ativação?',
    mtConfirmation, [mrYes, 'Sim', mrNo, 'Não'], 0) <> mrYes then
    Exit;

  Query_chave.Close;
  Query_chave.ParamByName('user_id').AsInteger := usuario_id;
  Query_chave.ParamByName('game_id').AsInteger := gameId;
  Query_chave.Open;

  if Query_chave.IsEmpty then
  begin
    ShowMessage('Chave não encontrada!');
    Query_chave.Close;
    Exit;
  end;

  Edit_chave.Text := Query_chave.FieldByName('key_code').AsString;
  Query_chave.Close;

  Panel_chave.Left := (Form7.ClientWidth - Panel_chave.Width) div 2;
  Panel_chave.Top  := (Form7.ClientHeight - Panel_chave.Height) div 2;
  Panel_chave.Visible := True;
end;

procedure TForm7.abrir_biblioteca;
var
  linha, coluna: integer;
  box: TPanel;
  image: TImage;
  labelNome: TLabel;
  stream: TMemoryStream;
begin
  if not usuario_logado then
  begin
    ShowMessage('É preciso ter feito login para acessar sua biblioteca!');
    Exit;
  end;

  while ScrollBox_biblioteca.ControlCount > 0 do
    ScrollBox_biblioteca.Controls[0].Free;

  linha := 0;
  coluna := 0;

  Query_biblioteca.Close;
  Query_biblioteca.ParamByName('user_id').AsInteger := usuario_id;
  Query_biblioteca.Open;

  if Query_biblioteca.IsEmpty then
  begin
    ShowMessage('Sua biblioteca está vazia!');
    Query_biblioteca.Close;
    Show;
    Exit;
  end;

  while not Query_biblioteca.EOF do
  begin
    if coluna > 3 then
    begin
      coluna := 0;
      linha := linha + 1;
    end;

    box := TPanel.Create(self);
    box.Parent := ScrollBox_biblioteca;
    box.Left := 15 + coluna * (400 + 50);
    box.Top := 15 + linha * (320 + 20);
    box.Width := 400;
    box.Height := 320;
    box.Color := RGBToColor($20, $20, $20);
    box.BevelOuter := bvNone;
    box.BevelInner := bvNone;
    box.Tag := Query_biblioteca.FieldByName('game_id').AsInteger;
    box.OnClick := @CardClick;
    box.Cursor := crHandPoint;

    image := TImage.Create(self);
    image.Parent := box;
    image.Top := 0;
    image.Left := 0;
    image.Width := 400;
    image.Height := 250;
    image.Stretch := true;
    image.Tag := Query_biblioteca.FieldByName('game_id').AsInteger;
    image.OnClick := @CardClick;
    image.Cursor := crHandPoint;

    try
      stream := TMemoryStream.Create;
      TBlobField(Query_biblioteca.FieldByName('image_byte')).SaveToStream(stream);
      stream.Position := 0;
      image.Picture.LoadFromStream(stream);
    finally
      stream.Free;
    end;

    labelNome := TLabel.Create(self);
    labelNome.Parent := box;
    labelNome.Caption := Query_biblioteca.FieldByName('name').AsString;
    labelNome.Top := 270;
    labelNome.Left := 20;
    labelNome.Font.Color := clWhite;
    labelNome.Font.Name := 'Segoe UI';
    labelNome.Font.Size := 15;
    labelNome.Font.Style := [fsBold];
    labelNome.Tag := Query_biblioteca.FieldByName('game_id').AsInteger;
    labelNome.OnClick := @CardClick;
    labelNome.Cursor := crHandPoint;

    coluna := coluna + 1;
    Query_biblioteca.Next;
  end;

  Query_biblioteca.Close;

  Panel_chave.Visible := False;
  Show;
end;

end.
