program nsqdelphi;

uses
  Vcl.Forms,
  mainTest in 'mainTest.pas' {Form1},
  ConnNsq in 'ConnNsq.pas',
  u_debug in 'u_debug.pas',
  pubNSq in 'pubNSq.pas',
  writedata in 'writedata.pas',
  define in 'define.pas',
  IDENTIFY in 'IDENTIFY.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
