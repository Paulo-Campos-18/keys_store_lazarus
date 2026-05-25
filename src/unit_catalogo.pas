unit unit_catalogo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ZConnection, ZDataset, ZAbstractRODataset;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    ScrollBoxCatalogo: TScrollBox;
    CnnCatalogo: TZConnection;
    QueryCatalogo: TZQuery;
    QueryCatalogoid: TZIntegerField;
    QueryCatalogoimage_byte: TZBlobField;
    QueryCatalogoname: TZRawStringField;
    QueryCatalogoprice: TZFMTBCDField;
    QueryCatalogostudio: TZRawStringField;
    procedure Image2Click(Sender: TObject);
    procedure CnnCatalogoAfterConnect(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Image2Click(Sender: TObject);
begin

end;

procedure TForm1.CnnCatalogoAfterConnect(Sender: TObject);
begin

end;

end.

