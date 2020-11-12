unit Integra.Onvio.Types;

interface

type
  TAmbiente = (aProducao, aHomologacao);
  TRequestType = (rtLogin, rtGetToken, rtRefreshToken, rtSendFile, rtReadStatusFile);

  TonExecuteRequest = procedure (aRequestType : TRequestType; aResponse : String; aStatusCode : Integer) of object;

const
  URL_homolocacao = 'https://api.onvio.com.br/dominio/invoice/v2/batches';
  URL_producao = 'https://api.onvio.com.br/dominio/invoice/v2/batches';
  URL_Auth_homologacao = 'https://auth.thomsonreuters.com/oauth/token';
  URL_Auth_producao = 'https://auth.thomsonreuters.com/oauth/token';

implementation

end.
