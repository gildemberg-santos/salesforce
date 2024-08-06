# frozen_string_literal: true

module Salesforce
  # A classe OAuthCodeRefreshToken é responsável por gerenciar a atualização do token de acesso
  # usando o token de atualização fornecido. Ela herda da classe `Salesforce::OAuth` e fornece
  # métodos para inicializar a instância com os parâmetros necessários e executar a solicitação
  # de atualização do token.
  #
  # @example
  #   oauth = Salesforce::OAuthCodeRefreshToken.new(
  #     client_id: "seu_client_id",
  #     client_secret: "seu_client_secret",
  #     refresh_token: "seu_refresh_token",
  #     api_version: "v52.0"
  #   )
  #   oauth.call
  #
  # @see Salesforce::OAuth
  class OAuthCodeRefreshToken < Salesforce::OAuth
    # Inicializa uma nova instância da classe OAuthCodeRefreshToken.
    #
    # Este método configura os parâmetros necessários para autenticação e validação com o Salesforce.
    # Ele levanta exceções se qualquer um dos parâmetros obrigatórios estiver ausente.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [String] :client_id O ID do cliente para autenticação. Se não for fornecido, será usado o valor padrão de `Salesforce.client_id`.
    # @option kwargs [String] :client_secret O segredo do cliente para autenticação. Se não for fornecido, será usado o valor padrão de `Salesforce.client_secret`.
    # @option kwargs [String] :refresh_token O token de atualização para obter um novo token de acesso.
    # @option kwargs [String] :api_version A versão da API do Salesforce. Se não for fornecida, será usada a versão padrão `API_VERSION`.
    #
    # @raise [Salesforce::Error] Se qualquer um dos parâmetros obrigatórios (`client_id`, `client_secret`, `refresh_token`, `api_version`) estiver ausente ou em branco.
    def initialize(**kwargs)
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @refresh_token = kwargs[:refresh_token]
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, "Client ID is required" if @client_id.blank?
      raise Salesforce::Error, "Client secret is required" if @client_secret.blank?
      raise Salesforce::Error, "Refresh token is required" if @refresh_token.blank?
      raise Salesforce::Error, "API version is required" if @api_version.blank?
    end

    # Executa a solicitação para atualizar o token de acesso usando o token de atualização.
    #
    # Este método cria uma nova instância de `Salesforce::Request` com a URL do endpoint,
    # envia a solicitação para atualizar o token de acesso e armazena os detalhes da resposta.
    #
    # @return [nil] Este método não retorna nenhum valor significativo.
    #
    # @raise [Salesforce::Error] Se a solicitação falhar ou a resposta não contiver os campos esperados.
    def call
      @response = Salesforce::Request.new(url: endpoint)
      response.refresh
      @access_token = response.json["access_token"]
      @instance_url = response.json["instance_url"]
      @id = response.json["id"]
      @token_type = response.json["token_type"]
      @issued_at = response.json["issued_at"]
      @signature = response.json["signature"]
      nil
    end

    private

    # Constrói a URL do endpoint para a solicitação de atualização do token.
    #
    # Este método combina o host com a rota do token e a query string do endpoint.
    #
    # @return [String] A URL completa do endpoint para a solicitação de atualização do token.
    def endpoint
      "#{host}token?#{endpoint_query}"
    end

    # Constrói a query string para a solicitação de atualização do token.
    #
    # Este método cria uma string de consulta codificada em URL com os parâmetros necessários
    # para a solicitação de atualização do token, incluindo o tipo de concessão, ID do cliente,
    # segredo do cliente e token de atualização.
    #
    # @return [String] A query string codificada em URL para a solicitação de atualização do token.
    def endpoint_query
      URI.encode_www_form(
        {
          grant_type: "refresh_token",
          client_id: @client_id,
          client_secret: @client_secret,
          refresh_token: @refresh_token
        }
      )
    end
  end
end
