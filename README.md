# IntegraOnvio
Integration API Onvio Class, refers integration XML files of Domínio Software.

# Utilization
1) Login Button: Create login auth on Onvio site. You need have a Callback URL to return it.
User and ClientSecret needs to be of yout software house.

2) Get Auth button gets token and refresh token. You need save ir to use on futures sends.

3) SendFile returns a ID, with it you can see the status file.

PLEASE, READ THE DOCUMENTATION OF API.

Set OnExecute event of class, there are all states of requests.

<details>
  <summary>Português</summary>

    ```
    Classe de integração da API Onvio, referente integração de XMLs do software Domínio.

    # Utilização
    1) Botão Login: Autentica o usuário e senha do cliente no site da Onvio. 
    obs: Você precisa ter uma URL de callback para retornar o login. O User e o ClientSecret     também precisam ser da SOFTWAREHOUSE.
    
    2) Get Auth obtem o token e refresh token. Salve esses dados para os próximos usos.

    3) Enviar arquivo retornará um ID, com esse id você consulta o status do arquivo, se já     foi processado.

    VALE MUITO A PENA LER A DOCUMENTAÇÃO DO PROJETO.

    Implemente o evento Onexecute da classe, nele tem todos os status de envio.
</details>