# frozen_string_literal: true

# O módulo Salesforce fornece classes e métodos para interagir com a API do Salesforce.
# Ele inclui a classe `OAuth`, que é responsável por gerenciar a autenticação OAuth com o Salesforce.
#
# @example
#   oauth = Salesforce::OAuth.new(
#     client_id: "seu_client_id",
#     client_secret: "seu_client_secret",
#     username: "seu_username",
#     password: "seu_password",
#     security_token: "seu_security_token"
#   )
#   oauth.call
#   puts oauth.access_token  # => "seu_access_token"
#
# @see Salesforce::OAuth
module Salesforce
  # A classe OAuth é responsável por gerenciar a autenticação OAuth com o Salesforce.
  # Ela permite a inicialização com as credenciais do cliente e fornece métodos para obter tokens de acesso.
  #
  # @attr_reader [String] access_token O token de acesso obtido após a autenticação.
  # @attr_reader [String] instance_url A URL da instância do Salesforce.
  # @attr_reader [String] id O ID do usuário autenticado.
  # @attr_reader [String] token_type O tipo de token obtido.
  # @attr_reader [String] issued_at A data e hora em que o token foi emitido.
  # @attr_reader [String] signature A assinatura do token.
  # @attr_reader [Hash] response A resposta completa da solicitação de autenticação.
  class OAuth
    attr_reader :access_token, :instance_url, :id, :token_type, :issued_at, :signature, :response

    # Inicializa uma nova instância da classe OAuth.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [String] :client_id O ID do cliente.
    # @option kwargs [String] :client_secret O segredo do cliente.
    # @option kwargs [String] :username O nome de usuário.
    # @option kwargs [String] :password A senha do usuário.
    # @option kwargs [String] :security_token O token de segurança.
    # @option kwargs [String] :api_version A versão da API.
    #
    # @raise [Salesforce::Error] Se qualquer um dos parâmetros obrigatórios estiver ausente.
    def initialize(**kwargs)
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @username = kwargs[:username] || Salesforce.username
      @password = kwargs[:password] || Salesforce.password
      @security_token = kwargs[:security_token] || Salesforce.security_token
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, "Client ID is required" if @client_id.blank?
      raise Salesforce::Error, "Client secret is required" if @client_secret.blank?
      raise Salesforce::Error, "Username is required" if @username.blank?
      raise Salesforce::Error, "Password is required" if @password.blank?
      raise Salesforce::Error, "Security token is required" if @security_token.blank?
      raise Salesforce::Error, "API version is required" if @api_version.blank?
    end

    # Realiza a chamada de autenticação OAuth e armazena os tokens de acesso.
    #
    # @raise [Salesforce::Error] Se a solicitação de autenticação falhar.
    def call
      @response = Salesforce::Request.new(url: endpoint)
      response.post
      @access_token = response.json["access_token"]
      @instance_url = response.json["instance_url"]
      @id = response.json["id"]
      @token_type = response.json["token_type"]
      @issued_at = response.json["issued_at"]
      @signature = response.json["signature"]
      nil
    end

    private

    # Retorna o endpoint completo para a solicitação de autenticação.
    #
    # @return [String] A URL do endpoint de autenticação.
    def endpoint
      "#{host}token?#{endpoint_query}"
    end

    # Retorna a query string para a solicitação de autenticação.
    #
    # @return [String] A query string codificada.
    def endpoint_query
      URI.encode_www_form(
        {
          grant_type: "password",
          client_id: @client_id,
          client_secret: @client_secret,
          username: @username,
          password: @password + @security_token
        }
      )
    end

    # Retorna a URL base do endpoint de autenticação do Salesforce.
    #
    # @return [String] A URL base do endpoint de autenticação.
    def host
      "https://login.salesforce.com/services/oauth2/"
    end
  end
end
