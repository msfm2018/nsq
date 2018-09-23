unit mainTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent,
  ConnectionUtils, IdComponent, pubNSq, IdTCPConnection, IdTCPClient, ConnNsq,
  define, Vcl.StdCtrls, IdHTTP;

type
  TMyThread = class(TThread)
  end;

  TForm1 = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Button1: TButton;
    IdHTTP1: TIdHTTP;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  commandBuilder: TStringBuilder;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin

  pub('test', 'test', Edit1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin

  sub('test', 'test');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  nsqip := Trim(Edit2.Text);
  if connectNsq then
    Button3.Enabled := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  caption := ComputerName;
end;

end.

