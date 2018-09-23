unit IDENTIFY;

interface

type
  TIDENTIFY = class
  public
    client_id: string;    //本机计算机名
    deflate: Boolean;  //false
    deflate_level: integer;
    feature_negotiation: Boolean;
    heartbeat_interval: Integer;
    hostname: string;    //本机计算机名
    long_id: string;     //本机计算机名
    msg_timeout: Integer;
    output_buffer_size: Integer;
    output_buffer_timeout: Integer;
    sample_rate: Integer;
    short_id: string;     //本机计算机名
    snappy: Boolean;
    tls_v1: Boolean;
    user_agent: string;       //go-nsq/1.0.7
  end;

implementation





    {"client_id":"LAPTOP-FV2TOBTH","deflate":false,"deflate_level":6,"feature_negotiation":true,
    "heartbeat_interval":30000,"hostname":"LAPTOP-FV2TOBTH","long_id":"LAPTOP-FV2TOBTH","msg_timeout":0,
    "output_buffer_size":16384,"output_buffer_timeout":250,"sample_rate":0,"short_id":"LAPTOP-FV2TOBTH",
    "snappy":false,"tls_v1":false,"user_agent":"go-nsq/1.0.7"}
end.

