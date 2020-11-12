unit Integra.Onvio;

interface

uses
  System.SysUtils, Integra.Onvio.Classes, Integra.Onvio.Types, System.JSON;

type
  TIntegraOnvio = Class
  private
    FonExecuteRequest: TonExecuteRequest;
    FRefreshToken: String;
    FCode: String;
    FClientID: String;
    FCallbackURI: String;
    FClientSecret: String;
    FToken: String;
    FAmbiente: TAmbiente;
    procedure SetonExecuteRequest(const Value: TonExecuteRequest);
    procedure SetAmbiente(const Value: TAmbiente);
    procedure SetCallbackURI(const Value: String);
    procedure SetClientID(const Value: String);
    procedure SetClientSecret(const Value: String);
    procedure SetCode(const Value: String);
    procedure SetRefreshToken(const Value: String);
    procedure SetToken(const Value: String);
  public
    property Code: String read FCode write SetCode;
    property CallbackURI: String read FCallbackURI write SetCallbackURI;
    property ClientSecret: String read FClientSecret write SetClientSecret;
    property ClientID: String read FClientID write SetClientID;
    property RefreshToken : String read FRefreshToken write SetRefreshToken;
    property Ambiente: TAmbiente read FAmbiente write SetAmbiente;
    property Token : String read FToken write SetToken;

    procedure Login;

    function GetAuth : TJSONObject;
    function SendFile(const aFileName : String; var FileID : String ) : Boolean;
    function StatusFile(const aFileID : String; var aMessage : String) : Boolean;

    property onExecuteRequest : TonExecuteRequest read FonExecuteRequest write SetonExecuteRequest;
  End;

implementation

uses
  Vcl.Dialogs;

{ TIntegraOnvio }

function TIntegraOnvio.GetAuth: TJSONObject;
begin
  Result :=
    TOnvio
      .New
        .onExecuteRequest(onExecuteRequest)
        .callbackURI(FCallbackURI)
        .ClientID(FClientID)
        .ClientSecret(FClientSecret)
        .Code(FCode)
        .GetAuth
        .GetKeys(FToken, FRefreshToken)
        .Response;
end;

procedure TIntegraOnvio.Login;
begin
  FCode :=
    TOnvio.New.Ambiente(FAmbiente).ClientID(FClientID).CallbackURI(FCallbackURI).Login;
end;

function TIntegraOnvio.SendFile(const aFileName: String;
  var FileID: String): Boolean;
begin
  Result :=
    TOnvio
      .New
        .onExecuteRequest(onExecuteRequest)
        .Ambiente(FAmbiente)
        .SendFile(aFileName, FileID)
        .GetKeys(FToken, FRefreshToken)
        .Status;
end;

procedure TIntegraOnvio.SetAmbiente(const Value: TAmbiente);
begin
  FAmbiente := Value;
end;

procedure TIntegraOnvio.SetCallbackURI(const Value: String);
begin
  FCallbackURI := Value;
end;

procedure TIntegraOnvio.SetClientID(const Value: String);
begin
  FClientID := Value;
end;

procedure TIntegraOnvio.SetClientSecret(const Value: String);
begin
  FClientSecret := Value;
end;

procedure TIntegraOnvio.SetCode(const Value: String);
begin
  FCode := Value;
end;

procedure TIntegraOnvio.SetonExecuteRequest(const Value: TonExecuteRequest);
begin
  FonExecuteRequest := Value;
end;

procedure TIntegraOnvio.SetRefreshToken(const Value: String);
begin
  FRefreshToken := Value;
end;

procedure TIntegraOnvio.SetToken(const Value: String);
begin
  FToken := Value;
end;

function TIntegraOnvio.StatusFile(const aFileID: String;
  var aMessage: String): Boolean;
begin
  Result :=
    TOnvio
      .New
        .onExecuteRequest(onExecuteRequest)
        .StatusFile(aFileID, aMessage)
        .GetKeys(FToken, FRefreshToken)
        .Status;
end;

end.

