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
    campo_primeiro_nome: TEdit;
    campo_ultimo_nome: TEdit;
    campo_apelido: TEdit;
    campo_email_regis: TEdit;
    campo_senha_regis: TEdit;
    campo_idade: TEdit;
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
    Label8: TLabel;
    Panel_registrar: TPanel;
    Panel_login: TPanel;
    Query_usuario: TZQuery;
    Query_registrar: TZQuery;
    btn_voltar_login: TSpeedButton;
    btn_registrase: TSpeedButton;
    procedure btn_loginClick(Sender: TObject);
    procedure btn_registraseClick(Sender: TObject);
    procedure btn_voltar_loginClick(Sender: TObject);
    procedure campo_primeiro_nomeChange(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure btn_recuperar_senhaClick(Sender: TObject);
    procedure btn_registrarClick(Sender: TObject);
    procedure Label7Click(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;
  usuario_logado: boolean;
  usuario_id: Integer;

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
begin
  Panel_login.visible := false;
  Panel_registrar.visible := true;
end;

procedure TForm3.Label7Click(Sender: TObject);
begin

end;

procedure TForm3.btn_loginClick(Sender: TObject);
begin
  try
  Query_usuario.Close;
   Query_usuario.ParamByName('email').AsString := campo_email.Caption;
   Query_usuario.ParamByName('senha').AsString := campo_senha.Caption;
   Query_usuario.Open;

   if not Query_usuario.IsEmpty then
    begin
      ShowMessage('Login realizado');
      usuario_logado := true;
      usuario_id := Query_usuario.FieldByName('id').AsInteger;
      close;
    end
    else
    begin
     ShowMessage('Usuário ou senha incorretos');
    end;

  except
   on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;

end;

procedure TForm3.btn_registraseClick(Sender: TObject);
begin
  if (Trim(campo_primeiro_nome.Text) = '') or
     (Trim(campo_ultimo_nome.Text) = '') or
     (Trim(campo_apelido.Text) = '') or
     (Trim(campo_senha_regis.Text) = '') or
     (Trim(campo_idade.Text) = '') or
     (Trim(campo_email_regis.Text) = '') then
  begin
    ShowMessage('Todos os campos precisam ser preenchidos!');
    Exit;
  end;

  try
   Query_registrar.Close;
   Query_registrar.ParamByName('primeiro_nome').AsString := campo_primeiro_nome.Text;
   Query_registrar.ParamByName('ultimo_nome').AsString := campo_ultimo_nome.Text;
   Query_registrar.ParamByName('nickname').AsString := campo_apelido.Text;
   Query_registrar.ParamByName('email').AsString := campo_email_regis.Text;
   Query_registrar.ParamByName('senha').AsString := campo_senha_regis.Text;
   Query_registrar.ParamByName('idade').AsInteger := StrToInt(campo_idade.Text);
   Query_registrar.ExecSQL;

   ShowMessage('Usuário registrado com sucesso!');
   Panel_login.visible := true;
   Panel_registrar.visible := false;
   except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
    end;
   end;



procedure TForm3.btn_voltar_loginClick(Sender: TObject);
begin
  Panel_registrar.visible := false;
  Panel_login.visible := true;
end;

procedure TForm3.campo_primeiro_nomeChange(Sender: TObject);
begin

end;



end.

