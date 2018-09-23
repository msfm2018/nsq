unit ConnectionUtils;

interface

uses
  System.SysUtils;

const
  NL = #10;
  MAGIC_V2 = '  V2';

type
  FrameType = (FRAMETYPERESPONSE, FRAMETYPEERROR, FRAMETYPEMESSAGE);


function fromInt(typeId: Integer): FrameType;
//  function subscribe(topic, channel, shortId, longId: string): string;

implementation

//uses
//  ConnNsq;

function fromInt(typeId: Integer): FrameType;
begin
  case (typeId) of

    0:
      result := FrameType.FRAMETYPERESPONSE;
    1:
      result := FrameType.FRAMETYPEERROR;
    2:
      result := FrameType.FRAMETYPEMESSAGE;
  end;

end;


end.

