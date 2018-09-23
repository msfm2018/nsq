unit ConnNsq;

interface

uses
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, ConnectionUtils,
  u_debug, IdGlobal, define, IDENTIFY, System.Classes, winapi.Windows, Sysutils,
  DBXJSON, DBXJSONReflect, SyncObjs, ActiveX, messages, Contnrs, writedata,
  System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMyThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
  end;

var
  IdTCPClient1: TIdTCPClient;
  sm: TStringStream;
  MyThread: TMyThread;

procedure sub(topic, channel: string);

function connectNsq: boolean;

implementation

uses
  REST.JSON;

function connectNsq: boolean;
var
  data: string;
  bby: char;
  ity: TIDENTIFY;
  js: string;
begin
  result := False;
  if nsqip = '' then
  begin
    debug.Show(' ip is "" ');
    exit;
  end;

  IdTCPClient1.Host := nsqip;
  IdTCPClient1.Port := 4150;
  IdTCPClient1.Connect;

  MyThread := TMyThread.Create(True);
  MyThread.Start;

  //版本认证
  IdTCPClient1.IOHandler.Write(MAGIC_V2);

  //IDENTIFY
  FreeMem(FData);
  FData := nil;
  WriteStr('IDENTIFY');

  //  write nl
  bby := #10;
  WriteBufData(bby, 1);

  ity := TIDENTIFY.create;
  with ity do
  begin
    client_id := ComputerName;      //本机计算机名

    deflate := false;
    deflate_level := 6;
    feature_negotiation := true;
    heartbeat_interval := 30000;
    hostname := ComputerName;    //本机计算机名
    long_id := ComputerName;     //本机计算机名
    msg_timeout := 0;
    output_buffer_size := 16384;
    output_buffer_timeout := 250;
    sample_rate := 0;
    short_id := ComputerName;     //本机计算机名
    snappy := false;
    tls_v1 := false;
    user_agent := 'delphi/10.2.2';
  end;

  js := TJson.ObjectToJsonString(ity);
  ity.Free;


   //write size
  Protocolby := PutUint32(SizeOf(Byte) * Length(js));
  WriteBufData(Protocolby[0], 4, true);
  //   write  data
  WriteStr(js);

  bs := RawToBytes(fdata[0], FLen);
  IdTCPClient1.IOHandler.write(bs);





//  //订阅
//  FreeMem(FData);
//  FData := nil;
//  WriteStr('SUB ');
//
//  WriteStr('test');
//  WriteStr(' ');
//  WriteStr('test');
//  bby := #10;
//  WriteBufData(bby, 1);
//  bs := RawToBytes(fdata[0], FLen);
//  IdTCPClient1.IOHandler.write(bs);
//
//// 准备接收
////   RDY 9
//  FreeMem(FData);
//  FData := nil;
//  WriteStr('RDY 9');
//  bby := #10;
//  WriteBufData(bby, 1);
//  bs := RawToBytes(fdata[0], FLen);
//  IdTCPClient1.IOHandler.write(bs);
  result := true;
end;

procedure sub(topic, channel: string);
var
  bby: char;
begin
 //订阅
  FreeMem(FData);
  FData := nil;
  WriteStr('SUB ');

  WriteStr(topic);
  WriteStr(' ');
  WriteStr(channel);
  bby := #10;
  WriteBufData(bby, 1);
  bs := RawToBytes(fdata[0], FLen);
  IdTCPClient1.IOHandler.write(bs);


// 准备接收
//   RDY 9
  FreeMem(FData);
  FData := nil;
  WriteStr('RDY 9');
  bby := #10;
  WriteBufData(bby, 1);
  bs := RawToBytes(fdata[0], FLen);
  IdTCPClient1.IOHandler.write(bs);
end;




{ TMyThread }
constructor TMyThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);

end;

procedure TMyThread.Execute;
var
  bby: char;
  bb: TArray<byte>;
  attempts: integer;
  nanosecond_timestamp: int64;
  message_ID: string;
  body: string;
  inx: integer;
begin
//为了便于更加了解 协议 全都写这里了
  while not Terminated do
  begin
    Sleep(1);
    if (IdTCPClient1 = nil) or ((IdTCPClient1 <> nil) and (not IdTCPClient1.Connected)) then
      Continue;

    sm.Clear;
    IdTCPClient1.IOHandler.ReadStream(sm);
    sm.Position := 0;

      // ReadResponse is a client-side utility function to read from the supplied Reader
      // according to the NSQ protocol spec:
      //
      //    [x][x][x][x][x][x][x][x]...
      //    |  (int32) || (binary)
      //    |  4-byte  || N-byte
      //    ------------------------...
      //        size       data

      //数据长度 已经由delphi过滤掉 不需要单独解析
      //所有回复 都集中在这里 包括 返回ok
    SetLength(bb, 4);
    ZeroMemory(@bb[0], 4);
    sm.ReadBuffer(bb, 4);

    inx := uint32(bb[3]) or (uint32(bb[2]) shl 8) or (uint32(bb[1]) shl 16) or (uint32(bb[0]) shl 24);

    case fromInt(inx) of
      FRAMETYPERESPONSE:
        begin

          body := sm.ReadString(sm.Size - 4);
          if body = 'OK' then     //返回的 [0][0][0][0]ok数据
            Continue;

          if body = '_heartbeat_' then
          begin
            FreeMem(FData);
            FData := nil;
             //   NOP\n     需要返回
            WriteStr('NOP');
            bby := #10;
            WriteBufData(bby, 1);
            bs := RawToBytes(fdata[0], FLen);
            IdTCPClient1.IOHandler.write(bs);

          end;

        end;
      FRAMETYPEERROR:
        begin
          //error
        end;
      FRAMETYPEMESSAGE:
        begin

          // DecodeMessage deserializes data (as []byte) and creates a new Message
          // message format:
          //  [x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x][x]...
          //  |       (int64)        ||    ||      (hex string encoded in ASCII)           || (binary)
          //  |       8-byte         ||    ||                 16-byte                      || N-byte
          //  ------------------------------------------------------------------------------------------...
          //    nanosecond timestamp    ^^                   message ID                       message body
          //                         (uint16)
          //                          2-byte
          //                         attempts
          //                  00 00 00 23 00 00 00 02 15 56 EA 20 C3 34 07 58
          //00 01 30 61 35 36 38 35 34 32 37 38 63 63 32 30
          //30 30 45 64 69 74 31

            //nanosecond_timestamp 8byte
          SetLength(bb, 8);
          ZeroMemory(@bb[0], 8);
          sm.ReadBuffer(bb, 8);
              //毫微秒时间戳
          nanosecond_timestamp := uint64(bb[7]) or (uint64(bb[6]) shl 8) or (uint64(bb[5]) shl 16) or (uint64(bb[4]) shl 24) or (uint64(bb[3]) shl 32) or (uint64(bb[2]) shl 40) or (uint64(bb[1]) shl 48) or (uint64(bb[0]) shl 56);



            //attempts 2byte
          SetLength(bb, 2);
          ZeroMemory(@bb[0], 2);
          sm.ReadBuffer(bb, 2);
          attempts := uint16(bb[1]) or (uint16(bb[0]) shl 8);


             //message_ID 16 byte
          SetLength(bb, 16);
          ZeroMemory(@bb[0], 16);
          sm.ReadBuffer(bb, 16);

          message_ID := '';
          for inx := 0 to 15 do
          begin
            message_ID := message_ID + char(bb[inx]); //inttohex(bb[inx],2);
          end;


                                       //sm.Size总接收字节数
          body := sm.ReadString(sm.Size - 8 - 2 - 16);

          debug.show(body);

            //FIN <message_id>\n   成功处理完一条消息
//            46 49 4E 20 30 61 35 36 39 31 30 63 35 62 34 63 32 30 30 30 0A

          FreeMem(FData);
          FData := nil;
          WriteStr('FIN ');
          WriteStr(message_ID);

          bby := #10;
          WriteBufData(bby, 1);
          bs := RawToBytes(fdata[0], FLen);
          IdTCPClient1.IOHandler.write(bs);
        end;
    end;

  end;
end;

initialization
  sm := TStringStream.create;
  IdTCPClient1 := TIdTCPClient.Create(nil);
//  connectNsq();

finalization
  IdTCPClient1.Disconnect;
  IdTCPClient1.Free;
  sm.Free;

end.

