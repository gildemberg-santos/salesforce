# frozen_string_literal: true

# O módulo Salesforce fornece classes e métodos para interagir com a API do Salesforce.
# Ele inclui a classe `OAuthCode`, que é responsável por gerenciar a autenticação OAuth com o fluxo de código de autorização.
#
# @example
#   oauth_code = Salesforce::OAuthCode.new(
#     client_id: "seu_client_id",
#     client_secret: "seu_client_secret",
#     redirect_uri: "sua_redirect_uri"
#   )
#   oauth_code.code = "seu_codigo_de_autorizacao"
#   oauth_code.call
#   puts oauth_code.access_token # => "seu_access_token"
#
# @see Salesforce::OAuth
module Salesforce
  # A classe OAuthCode é responsável por gerenciar a autenticação OAuth com o fluxo de código de autorização.
  # Ela permite a inicialização com as credenciais do cliente e fornece métodos para obter tokens de acesso e refresh tokens.
  #
  # @attr_reader [String] authorize A URL de autorização gerada.
  # @attr_reader [String] refresh_token O refresh token obtido após a autenticação.
  # @attr_accessor [String] code O código de autorização obtido após a autorização do usuário.
  class OAuthCode < Salesforce::OAuth
    attr_reader :authorize, :refresh_token
    attr_accessor :code

    # Inicializa uma nova instância da classe OAuthCode.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [String] :client_id O ID do cliente.
    # @option kwargs [String] :client_secret O segredo do cliente.
    # @option kwargs [String] :redirect_uri A URI de redirecionamento.
    # @option kwargs [String] :api_version A versão da API.
    #
    # @raise [Salesforce::Error] Se qualquer um dos parâmetros obrigatórios estiver ausente.
    def initialize(**kwargs)
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @redirect_uri = kwargs[:redirect_uri] || Salesforce.redirect_uri
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, "Client ID is required" if @client_id.blank?
      raise Salesforce::Error, "Client secret is required" if @client_secret.blank?
      raise Salesforce::Error, "Redirect URI is required" if @redirect_uri.blank?
      raise Salesforce::Error, "API version is required" if @api_version.blank?

      endpoint_authorize
    end

    # Realiza a chamada de autenticação OAuth e armazena os tokens de acesso e refresh token.
    #
    # @raise [Salesforce::Error] Se a solicitação de autenticação falhar.
    def call
      @response = Salesforce::Request.new(url: endpoint)
      response.post
      @access_token = response.json["access_token"]
      @refresh_token = response.json["refresh_token"]
      @id = response.json["id"]
      @token_type = response.json["token_type"]
      @issued_at = response.json["issued_at"]
      @signature = response.json["signature"]
      @instance_url = response.json["instance_url"]
      nil
    end

    private

    # Gera a URL de autorização para o fluxo de código de autorização.
    #
    # @return [String] A URL de autorização.
    def endpoint_authorize
      @authorize = "#{host}authorize?#{endpoint_authorize_query}"
    end

    # Retorna a query string para a solicitação de autorização.
    #
    # @return [String] A query string codificada.
    def endpoint_authorize_query
      URI.encode_www_form(
        {
          response_type: "code",
          client_id: @client_id,
          redirect_uri: @redirect_uri
        }
      )
    end

    # Retorna o endpoint completo para a solicitação de autenticação.
    # Verifica se o código de autorização está presente antes de construir a URL.
    #
    # @raise [Salesforce::Error] Se o código de autorização estiver ausente.
    #
    # @return [String] A URL do endpoint de autenticação.
    def endpoint
      raise Salesforce::Error, "Code is required" if @code.blank?

      "#{host}token?#{endpoint_query}"
    end

    # Gera a query string para a solicitação de token de autenticação.
    # A query string inclui o tipo de concessão, ID do cliente, segredo do cliente, URI de redirecionamento, código de autorização e formato da resposta.
    #
    # @return [String] A query string codificada para a solicitação de token.
    def endpoint_query
      URI.encode_www_form(
        {
          grant_type: "authorization_code",
          client_id: @client_id,
          client_secret: @client_secret,
          redirect_uri: @redirect_uri,
          code: @code,
          format: "json"
        }
      )
    end
  end
end
