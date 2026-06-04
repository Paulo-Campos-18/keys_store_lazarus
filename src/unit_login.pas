unit unit_login;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, DBCtrls,
  StdCtrls, Buttons, ZDataset, ZSqlUpdate;

type

  { TForm3 } // Lembrar 1200 x 750

  TForm3 = class(TForm)
    campo_email: TEdit;
    campo_senha: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label2: TLabel;
    btn_login: TSpeedButton;
    btn_recuperar_senha: TSpeedButton;
    btn_registrar: TSpeedButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel_registrar: TPanel;
    Panel_login: TPanel;
    Query_usuario: TZQuery;
    Query_registrar: TZQuery;
    procedure btn_loginClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure btn_recuperar_senhaClick(Sender: TObject);
    procedure btn_registrarClick(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

 uses unit_catalogo;

{$R *.lfm}

{ TForm3 }

procedure TForm3.Image1Click(Sender: TObject);
begin

end;

procedure TForm3.btn_recuperar_senhaClick(Sender: TObject);
begin
ShowMessage('Que pena!' + sLineBreak + 'Entre em contato com o administrador no email: coitadoDeMim@gmail.com');
end;

procedure TForm3.btn_registrarClick(Sender: TObject);
var
  //btn_confirmar_senha : TEdit;
  //label_confirmar_senha :TLabel;
begin
  (*btn_login.Visible := False;
  //Terminar de arrumar a UI + Insert no bd
  btn_confirmar_senha.Width:= 256;
  btn_confirmar_senha.Height:= 23;
  btn_confirmar_senha.Top:= 490;
  btn_confirmar_senha.Left:= 530;
  btn_confirmar_senha.MaxLength:= 530;

  label_confirmar_senha.Font.Size := 14;
  label_confirmar_senha.Top := 490;
  label_confirmar_senha.Left := 420;
  label_confirmar_senha.Height := 25;
  label_confirmar_senha.Width := 56;
  label_confirmar_senha.Caption := 'Confirmar Senha';
  *)

  Panel_login.visible := false;

end;

procedure TForm3.btn_loginClick(Sender: TObject);
begin
  Query_usuario.Close;
   Query_usuario.ParamByName('email').AsString := campo_email.Caption;
   Query_usuario.ParamByName('senha').AsString := campo_senha.Caption;
   Query_usuario.Open;

   if not Query_usuario.IsEmpty then
    begin
      ShowMessage('Login realizado');
    end
    else
    begin
     ShowMessage('Usuário ou senha incorretos');
    end;

end;

end.

