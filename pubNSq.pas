unit pubNSq;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  u_debug, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, ConnNsq, Vcl.StdCtrls, IdHTTP,
  define;

var
  IdHTTP1: TIdHTTP;
  puburl: string;

procedure pub(topic, channel, data: string);

implementation

procedure pub(topic, channel, data: string);
var
  RequestStream: TStringStream;
begin
  puburl := 'http://' + nsqip + ':4151/pub?topic=' + topic + '&channel=' + channel;

  RequestStream := TStringStream.Create('');
  RequestStream.WriteString(data);

  IdHTTP1.Post(puburl, RequestStream);



  RequestStream.Free;

end;

initialization
  IdHTTP1 := TIdHTTP.Create(nil);

finalization
  IdHTTP1.Free;

end.

