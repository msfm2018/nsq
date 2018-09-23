unit writedata;

interface

uses
  Winapi.Windows, System.SysUtils, IdGlobal, u_debug, System.Classes;

var
  Protocolby: TArray<byte>;
  bs: TIdBytes;
  FCommand: byte;
  FData: Pansichar;
  FLen: integer;
  FPosition: integer;

procedure WriteStr(Value: AnsiString);

procedure WriteBufData(var buf; ALen: integer; WriteHead: Boolean = false);


function PutUint32(i: Integer): TArray<byte>;

implementation

procedure WriteBufData(var buf; ALen: integer; WriteHead: Boolean = false);
begin

  if FData = nil then
  begin
    GetMem(FData, ALen);
    Move(buf, (FData)^, ALen);
    FPosition := ALen;
    FLen := FPosition;
    exit;
  end;
  ReallocMem(FData, FPosition + ALen);
  Move(buf, (FData + FPosition)^, ALen);
  FPosition := FPosition + ALen;
  FLen := FPosition;

end;

procedure WriteStr(Value: AnsiString);
var
  l: integer;
begin
  l := Length(Value);
  WriteBufData(Value[1], l);
end;




function PutUint32(i: Integer): TArray<byte>;
begin
  SetLength(result, 4);

  result[3] := ($FF and i);
  result[2] := ($FF00 and i) shr 8;
  result[1] := ($FF0000 and i) shr 16;
  result[0] := ($FF000000 and i) shr 24;
end;
//


end.

