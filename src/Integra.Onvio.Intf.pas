unit Integra.Onvio.Intf;

interface

uses
  Integra.Onvio.Types, System.JSON;

type
  iOnvio = interface
    function Ambiente(const Value: TAmbiente) : iOnvio;
    function CallbackURI(const Value : String) : iOnvio;
    function ClientID(const Value : String) : iOnvio;
    function ClientSecret(const Value : String) : iOnvio;
    function Code(const Value : String) : iOnvio;
    function onExecuteRequest(const vEvent : TonExecuteRequest) : iOnvio;

    function Response(var vResponse : TJSONObject) : iOnvio;

    function SendFile(const FileName : String; var msg : String) : iOnvio;
    function StatusFile(const vID : String; var CallBackStr : String) : iOnvio;
    function Status : Boolean;

    function GetAuth : iOnvio;
    function GetKeys(var token, refresh : String) : iOnvio;

    function Login : String;
  end;

implementation

end.
