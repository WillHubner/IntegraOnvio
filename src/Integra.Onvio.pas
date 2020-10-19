unit Integra.Onvio;

interface

uses
  IdMultipartFormData, System.Classes, IdSSLOpenSSL, System.JSON,
  IdIOHandlerSocket, IdIOHandlerStack, IdHTTP, IdIOHandler, IdSSL,
  REST.Authenticator.OAuth.WebForm.Win, System.SysUtils;

type
  TAmbiente = (aProducao, aHomologacao);
  TRequestType = (rtLogin, rtGetToken, rtRefreshToken, rtSendFile, rtReadStatusFile);

  TonExecuteRequest = procedure (aRequestType : TRequestType;aResponse : String; aStatusCode : Integer) of object;

  TIntegraOnvio = Class
  private
    FHTTP : TIdHTTP;
    FResponse : TJSONObject;
    Fcode: String;
    FcallbackURI: String;
    FClientSecret: String;
    FClientID: String;
    FRefreshToken : String;
    FToken : String;
    FonExecuteRequest: TonExecuteRequest;
    FURL : String;
    FURL_AUTH : String;
    FAmbiente: TAmbiente;

    procedure SetToken(const Value: String);
    procedure SetResponse(const Value: TJSONObject);
    procedure SetRefreshToken(const Value: String);
    procedure SetonExecuteRequest(const Value: TonExecuteRequest);
    procedure SetCode(const Value: String);
    procedure GetRefreshToken;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Login;
    procedure OnvioOnRedirectURI(const AURL: string; var DoCloseWebView: boolean);

    function callbackURI(const Value: String) : TIntegraOnvio;
    function ClientID(const Value: String) : TIntegraOnvio;
    function ClientSecret(const Value: String) : TIntegraOnvio;
    function Ambiente(const Value: TAmbiente) : TIntegraOnvio;

    function GetAuth : TJSONObject;
    function SendFile(const aFileName : String; var FileID : String ) : Boolean;
    function StatusFile(const aFileID : String; var aMessage : String) : Boolean;

    property Token : String read FToken write SetToken;
    property RefreshToken : String read FRefreshToken write SetRefreshToken;
    property Code : String read FCode write SetCode;
    property Response : TJSONObject read FResponse write SetResponse;
    property onExecuteRequest : TonExecuteRequest read FonExecuteRequest write SetonExecuteRequest;
  End;

const
  URL_homolocacao = 'https://api.onvio.com.br/dominio/invoice/v2/batches';
  URL_producao = 'https://api.onvio.com.br/dominio/invoice/v2/batches';
  URL_Auth_homologacao = 'https://auth.thomsonreuters.com/oauth/token';
  URL_Auth_producao = 'https://auth.thomsonreuters.com/oauth/token';

implementation

uses
  Vcl.Dialogs;

{ TIntegraOnvio }

function TIntegraOnvio.Ambiente(const Value: TAmbiente): TIntegraOnvio;
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

function TIntegraOnvio.callbackURI(const Value: String) : TIntegraOnvio;
begin
  Result := Self;
  FcallbackURI := Value;
end;

constructor TIntegraOnvio.Create;
begin
  FHTTP := TIdHTTP.Create(nil);

  FResponse := TJSONObject.Create;

  Ambiente(aProducao);
end;

destructor TIntegraOnvio.Destroy;
begin
  FHTTP.Free;

  inherited;
end;

function TIntegraOnvio.GetAuth: TJSONObject;
var
  vResult : String;
  vToken, vRefreshToken, vGrant_type, vRedirect_uri, vCode, vRealm  : String;

  FReqAuthParams : TStringList;
  sshSocketHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
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
    sshSocketHandler.SSLOptions.Method := sslvSSLv23;
    sshSocketHandler.SSLOptions.SSLVersions :=  [sslvSSLv23];
    FHTTP.IOHandler := sshSocketHandler;

    vResult := FHTTP.Post(FURL_AUTH, FReqAuthParams);

    FResponse := TJSONObject.ParseJSONValue(vResult) as TJSONObject;

    Result := FResponse;

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

procedure TIntegraOnvio.GetRefreshToken;
var
  vResult,refre_,grand_ : String;
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

procedure TIntegraOnvio.Login;
var
  wv: Tfrm_OAuthWebForm;
begin
  wv := Tfrm_OAuthWebForm.Create(nil);
  wv.OnAfterRedirect := OnvioOnRedirectURI;

  case FAmbiente of
    aProducao: wv.ShowModalWithURL('https://auth.thomsonreuters.com/authorize?client_id=WpzdY5wP8L23Ql3tz6gJ5fm9wcTKq0SX&response_type=code&audience=409f91f6-dc17-44c8-a5d8-e0a1bafd8b67&redirect_uri=http://34.219.13.232:2284/auth&scope=openid+profile+email+offline_access');
    aHomologacao: wv.ShowModalWithURL('https://auth.thomsonreuters.com/authorize?client_id=WpzdY5wP8L23Ql3tz6gJ5fm9wcTKq0SX&response_type=code&audience=409f91f6-dc17-44c8-a5d8-e0a1bafd8b67&redirect_uri=http://34.219.13.232:2284/auth&scope=openid+profile+email+offline_access');
  end;

  wv.Release;
end;

procedure TIntegraOnvio.OnvioOnRedirectURI(const AURL: string;
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

function TIntegraOnvio.ClientSecret(const Value: String) : TIntegraOnvio;
begin
  Result := Self;
  FClientSecret := Value;
end;

function TIntegraOnvio.SendFile(const aFileName : String; var FileID : String ) : Boolean;
var
  aResult : String;
  Bearer : String;
  FPostFileStream : TIdMultiPartFormDataStream;
  sshSocketHandler: TIdSSLIOHandlerSocketOpenSSL;
const
  USER_AGENT = 'User-Agent:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36';
  KEEP_ALIVE = 'Keep-Alive';
begin
  Result := False;

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



    Result := false;
    try

      try
        aResult := FHTTP.Post(FURL, FPostFileStream);

        Response := TJSONObject.ParseJSONValue(aResult) as TJSONObject;

        if Assigned(FonExecuteRequest) then
          begin
            case FHTTP.ResponseCode of
              201 :
                begin
                  FileID := Response.GetValue('id').Value;

                  FonExecuteRequest(rtSendFile, TJSONObject(Response.GetValue('status')).GetValue('message').Value, FHTTP.ResponseCode);

                  Result := True;
                end;

              400 : FonExecuteRequest(rtSendFile, 'Invalid data on request', FHTTP.ResponseCode);

              401 :
                begin
                  FonExecuteRequest(rtSendFile, 'Invalid access token', FHTTP.ResponseCode);
                  Result := false;
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
      if result = false then
        begin
          GetRefreshToken;

          SendFile(aFileName, FileID);
        end;
      sshSocketHandler.Free;
    end;

  finally
    if result = false then
    begin
      GetRefreshToken;

      SendFile(aFileName, FileID);
    end;
    FPostFileStream.Free;
  end;
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

procedure TIntegraOnvio.SetResponse(const Value: TJSONObject);
begin
  FResponse := Value;
end;

procedure TIntegraOnvio.SetToken(const Value: String);
begin
  FToken := Value;
end;

function TIntegraOnvio.StatusFile(const aFileID : String; var aMessage : String) : Boolean;
var
  aResponse : String;
begin
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

  Response := TJSONObject.ParseJSONValue(aResponse) as TJSONObject;

  aMessage := TJSONObject(Response.GetValue('status')).GetValue('message').Value;

  Result := (aMessage = 'Processado');

  if Assigned(FonExecuteRequest) then
    FonExecuteRequest(rtReadStatusFile, aMessage, FHTTP.ResponseCode)
end;

function TIntegraOnvio.ClientID(const Value: String) : TIntegraOnvio;
begin
  Result := Self;
  FClientID := Value;
end;

end.

