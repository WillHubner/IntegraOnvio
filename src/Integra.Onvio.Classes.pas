unit Integra.Onvio.Classes;

interface

uses
  Integra.Onvio.Intf, Integra.Onvio.Types,
  IdMultipartFormData, System.Classes, IdSSLOpenSSL, System.JSON,
  IdIOHandlerSocket, IdIOHandlerStack, IdHTTP, IdIOHandler, IdSSL,
  REST.Authenticator.OAuth.WebForm.Win;

type
  TOnvio = Class(TInterfacedObject, iOnvio)
  private
    FHTTP : TIdHTTP;
    Fcode: String;
    FcallbackURI: String;
    FClientSecret: String;
    FClientID: String;
    FRefreshToken : String;
    FAmbiente: TAmbiente;
    FToken : String;
    FURL : String;
    FURL_AUTH : String;
    FStatus : Boolean;
    FResponse : TJSONObject;
    FonExecuteRequest: TonExecuteRequest;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOnvio;

    procedure GetRefreshToken;
    procedure OnvioOnRedirectURI(const AURL: string; var DoCloseWebView: boolean);

    function Response(var vResponse : TJSONObject) : iOnvio;

    function Ambiente(const Value: TAmbiente) : iOnvio;
    function CallbackURI(const Value : String) : iOnvio;
    function ClientID(const Value : String) : iOnvio;
    function ClientSecret(const Value : String) : iOnvio;
    function Code(const Value : String) : iOnvio;
    function Token(const Value : String) : iOnvio;
    function RefreshToken(const Value : String) : iOnvio;
    function GetKeys(var token, refresh : String) : iOnvio;
    function onExecuteRequest(const vEvent : TonExecuteRequest) : iOnvio;

    function SendFile(const aFileName : String; var FileID : String) : iOnvio;
    function StatusFile(const aFileID : String; var aMessage : String) : iOnvio;
    function Status : Boolean;

    function GetAuth : iOnvio;
    function Login : String;
  End;

implementation

uses
  System.SysUtils;

{ TOnvio }

function TOnvio.Ambiente(const Value: TAmbiente): iOnvio;
begin
  Result := Self;

  case FAmbiente of
    aProducao:
      begin
        FURL := URL_producao;
        FURL_AUTH := URL_Auth_producao;
      end;

    aHomologacao:
      begin
        FURL := URL_homolocacao;
        FURL_AUTH := URL_Auth_homologacao;
      end;
  end;
end;

function TOnvio.CallbackURI(const Value: String): iOnvio;
begin
  Result := Self;

  FcallbackURI := Value;
end;

function TOnvio.ClientID(const Value: String): iOnvio;
begin
  Result := Self;

  FClientID := Value;
end;

function TOnvio.ClientSecret(const Value: String): iOnvio;
begin
  Result := Self;

  FClientSecret := Value;
end;

function TOnvio.Code(const Value: String): iOnvio;
begin
  Result := Self;

  Fcode := Value;
end;

constructor TOnvio.Create;
begin
  FHTTP := TIdHTTP.Create(nil);

  FResponse := TJSONObject.Create;
  FStatus := False;

  Ambiente(aProducao);
end;

destructor TOnvio.Destroy;
begin
  FHTTP.Free;

  inherited;
end;

function TOnvio.GetAuth: iOnvio;
var
  vResult : String;
  vToken, vRefreshToken, vGrant_type, vRedirect_uri, vCode : String;

  FReqAuthParams : TStringList;
  sshSocketHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := Self;

  vGrant_type := 'grant_type=authorization_code' ;
  vRedirect_uri := Concat('redirect_uri=', FcallbackURI) ;
  vCode := Concat('code=', Fcode) ;

  FReqAuthParams := TStringList.Create;

  try
    FReqAuthParams.Clear;
    FReqAuthParams.Add(vGrant_type);
    FReqAuthParams.Add(vRedirect_uri);
    FReqAuthParams.Add(vCode);

    FHTTP.Request.Clear;
    FHTTP.Request.ContentType := 'application/x-www-form-urlencoded';
    FHTTP.Request.BasicAuthentication := True;
    FHTTP.Request.Username := FClientID;
    FHTTP.Request.Password := FClientSecret;

    sshSocketHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
    sshSocketHandler.SSLOptions.SSLVersions := [sslvSSLv23, sslvTLSv1_2];
    FHTTP.IOHandler := sshSocketHandler;

    vResult := FHTTP.Post(FURL_AUTH, FReqAuthParams);

    FResponse := TJSONObject.ParseJSONValue(vResult) as TJSONObject;

//    Result := FResponse;

    if Assigned(FonExecuteRequest) then
      FonExecuteRequest(rtGetToken, 'Token created', FHTTP.ResponseCode);

    vToken := FResponse.GetValue('access_token').Value;
    vRefreshToken := FResponse.GetValue('refresh_token').Value;

    FToken := vToken;
    FRefreshToken := vRefreshToken;
  finally
    FReqAuthParams.Free;
  end;
end;

function TOnvio.GetKeys(var token, refresh: String): iOnvio;
begin
  Result := Self;

  token := FToken;
  refresh := FRefreshToken;
end;

procedure TOnvio.GetRefreshToken;
var
  vResult,refre_ : String;
  FReqAuthParams : TStringList;
begin
  FReqAuthParams := TStringList.Create;
  FToken := '';

  try
   refre_ := Concat('refresh_token=',FRefreshToken) ;

    FReqAuthParams.Clear;
    FReqAuthParams.Add('grant_type=refresh_token');
    FReqAuthParams.Add(refre_);

    FHTTP.Request.Clear;
    FHTTP.Request.ContentType := 'application/x-www-form-urlencoded';
    FHTTP.Request.BasicAuthentication := True;
    FHTTP.Request.Username := FClientID;
    FHTTP.Request.Password := FClientSecret;

    vResult := FHTTP.Post(FURL_AUTH, FReqAuthParams);

    FResponse := TJSONObject.ParseJSONValue(vResult) as TJSONObject;

    FToken := FResponse.GetValue('access_token').Value;
    FRefreshToken := FResponse.GetValue('refresh_token').Value;

    if Assigned(FonExecuteRequest) then
      FonExecuteRequest(rtRefreshToken, 'Token Created', FHTTP.ResponseCode)
  finally
    FReqAuthParams.Free;
  end;
end;

function TOnvio.Login: String;
var
  wv: Tfrm_OAuthWebForm;
begin
  Result := '';

  wv := Tfrm_OAuthWebForm.Create(nil);
  wv.OnAfterRedirect := OnvioOnRedirectURI;

  case FAmbiente of
    aProducao: wv.ShowModalWithURL('https://auth.thomsonreuters.com/authorize?client_id='+FClientID+'&response_type=code&audience=409f91f6-dc17-44c8-a5d8-e0a1bafd8b67&redirect_uri='+FcallbackURI+'&scope=openid+profile+email+offline_access');
    aHomologacao: wv.ShowModalWithURL('https://auth.thomsonreuters.com/authorize?client_id='+FClientID+'&response_type=code&audience=409f91f6-dc17-44c8-a5d8-e0a1bafd8b67&redirect_uri='+FcallbackURI+'&scope=openid+profile+email+offline_access');
  end;

  Result := Fcode;

  wv.Release;
end;

class function TOnvio.New: iOnvio;
begin
  Result := Self.Create;
end;

function TOnvio.onExecuteRequest(const vEvent: TonExecuteRequest): iOnvio;
begin
  Result := Self;

  FonExecuteRequest := vEvent;
end;

procedure TOnvio.OnvioOnRedirectURI(const AURL: string;
  var DoCloseWebView: boolean);
var
  LATPos: integer;
  LToken: string;
begin
  LATPos := Pos('code=', AURL);

  if (LATPos > 0) then
    begin
      LToken := Copy(AURL, LATPos + 5, Length(AURL));

      if (Pos('&', LToken) > 0) then
        begin
          LToken := Copy(LToken, 1, Pos('&', LToken) - 1);
        end;

      Fcode := LToken;

      if Assigned(FonExecuteRequest) then
        FonExecuteRequest(rtLogin, FCode, 200);

      if (LToken <> '') then
        DoCloseWebView := TRUE;
    end;
end;

function TOnvio.RefreshToken(const Value: String): iOnvio;
begin
  Result := Self;

  FRefreshToken := Value;
end;

function TOnvio.Response(var vResponse : TJSONObject) : iOnvio;
begin
  result := Self;

  vResponse := FResponse;
end;

function TOnvio.SendFile(const aFileName : String; var FileID : String) : iOnvio;
var
  aResult : String;
  Bearer : String;
  FPostFileStream : TIdMultiPartFormDataStream;
  sshSocketHandler: TIdSSLIOHandlerSocketOpenSSL;
const
  USER_AGENT = 'User-Agent:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36';
  KEEP_ALIVE = 'Keep-Alive';
begin
  Result := Self;

  FPostFileStream := TIdMultiPartFormDataStream.Create;

  try
    FPostFileStream.AddFormField('query', '{"boxe/File":true}', 'UTF-8', 'application/json');
    FPostFileStream.AddFile('file[]', aFileName, 'application/xml');

    FHTTP.Request.Clear;
    FHTTP.Request.BasicAuthentication := False;
    FHTTP.Request.UserAgent := USER_AGENT;
    FHTTP.Request.Connection := KEEP_ALIVE;
    FHTTP.Request.Accept := 'application/json';
    FHTTP.Request.ContentType := 'multipart/form-data';

    Bearer := Concat('Bearer ', FToken);

    FHTTP.Request.CustomHeaders.Clear;
    FHTTP.Request.CustomHeaders.Values['Authorization'] := Bearer;
    sshSocketHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
    sshSocketHandler.SSLOptions.Method := sslvTLSv1_2;
    sshSocketHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    FHTTP.IOHandler := sshSocketHandler;

    try
      try
        aResult := FHTTP.Post(FURL, FPostFileStream);

        FResponse := TJSONObject.ParseJSONValue(aResult) as TJSONObject;

        if Assigned(FonExecuteRequest) then
          begin
            case FHTTP.ResponseCode of
              201 :
                begin
                  FileID := FResponse.GetValue('id').Value;

                  FonExecuteRequest(rtSendFile, TJSONObject(FResponse.GetValue('status')).GetValue('message').Value, FHTTP.ResponseCode);

                  FStatus := True;
                end;

              400 : FonExecuteRequest(rtSendFile, 'Invalid data on request', FHTTP.ResponseCode);

              401 :
                begin
                  FonExecuteRequest(rtSendFile, 'Invalid access token', FHTTP.ResponseCode);
                  FStatus := false;
                end;
              404 : FonExecuteRequest(rtSendFile, 'Not found data', FHTTP.ResponseCode);
              500 : FonExecuteRequest(rtSendFile, 'Unexpected error on server', FHTTP.ResponseCode);
            end;
          end;
      except
        on e : exception do
          begin
            if Assigned(FonExecuteRequest) then
              FonExecuteRequest(rtSendFile, e.Message, FHTTP.ResponseCode)
            else
              raise Exception.Create(e.Message);
          end;
      end;

    finally
      if FStatus = false then
        begin
          GetRefreshToken;

          SendFile(aFileName, FileID);
        end;
      sshSocketHandler.Free;
    end;

  finally
    if FStatus = false then
    begin
//      GetRefreshToken;

      SendFile(aFileName, FileID);
    end;

    FPostFileStream.Free;
  end;
end;

function TOnvio.Status: Boolean;
begin
  Result := FStatus;
end;

function TOnvio.StatusFile(const aFileID : String; var aMessage : String) : iOnvio;
var
  aResponse : String;
begin
  Result := Self;

  FHTTP.Request.Clear;
  FHTTP.Request.BasicAuthentication := False;
  FHTTP.Request.Accept := 'application/json';

  FHTTP.Request.CustomHeaders.Clear;
  FHTTP.Request.CustomHeaders.Values['Authorization'] := 'Bearer ' + FToken;

  try
    aResponse := FHTTP.Get(FURL + '\'+aFileID);

    if FHTTP.ResponseCode = 401 then
      begin
        FonExecuteRequest(rtSendFile, 'Invalid access token', FHTTP.ResponseCode);
        GetRefreshToken;
        StatusFile(aFileID, aMessage);
      end;
  except
    on e : exception do
      begin
        if Assigned(FonExecuteRequest) then
          FonExecuteRequest(rtReadStatusFile, e.Message, FHTTP.ResponseCode)
        else
          raise Exception.Create(e.Message);
      end;
  end;

  FResponse := TJSONObject.ParseJSONValue(aResponse) as TJSONObject;

  aMessage := TJSONObject(FResponse.GetValue('status')).GetValue('message').Value;

  FStatus := (aMessage = 'Processado');

  if Assigned(FonExecuteRequest) then
    FonExecuteRequest(rtReadStatusFile, aMessage, FHTTP.ResponseCode)
end;

function TOnvio.Token(const Value: String): iOnvio;
begin
  Result := Self;

  FToken := Value;
end;

end.

