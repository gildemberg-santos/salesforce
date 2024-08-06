# frozen_string_literal: true

# O módulo Salesforce fornece classes e métodos para interagir com a API do Salesforce.
# Ele inclui a classe `Request`, que é responsável por fazer solicitações HTTP para o Salesforce,
# incluindo operações de POST, GET e refresh de tokens.
#
# @example
#   request = Salesforce::Request.new(url: "https://sua_instancia.salesforce.com/services/data/v52.0/sobjects/Lead")
#   request.access_token = "seu_access_token"
#   response = request.post(payload: { nome: "John Doe", email: "john.doe@example.com" })
#
# @see Salesforce::Request
module Salesforce
  # A classe Request é responsável por gerenciar as solicitações HTTP para a API do Salesforce.
  # Ela permite a inicialização com a URL do endpoint e fornece métodos para enviar solicitações
  # POST, GET e refresh de tokens.
  #
  # @attr_reader [Hash] json O corpo da resposta em formato JSON.
  # @attr_reader [Integer] status_code O código de status HTTP da resposta.
  # @attr_writer [String] access_token O token de acesso para autenticação.
  class Request
    attr_reader :json, :status_code
    attr_writer :access_token

    # Inicializa uma nova instância da classe Request.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [String] :url A URL do endpoint para a solicitação.
    #
    # @raise [Salesforce::Error] Se a URL não for fornecida.
    def initialize(**kwargs)
      @url = kwargs[:url]
      raise Salesforce::Error, "URL is required" if @url.blank?
    end

    # Envia uma solicitação POST para o endpoint especificado.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [Hash] :payload O payload a ser enviado no corpo da solicitação.
    #
    # @raise [Salesforce::Error] Se a resposta não tiver um código de status 200 ou 201.
    def post(**kwargs)
      response = HTTParty.post(@url, headers: headers, body: kwargs[:payload]&.to_json)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, handle_exception if @status_code != 201 && @status_code != 200
    end

    # Envia uma solicitação GET para o endpoint especificado.
    #
    # @raise [Salesforce::Error] Se a resposta não tiver um código de status 200.
    def get
      response = HTTParty.get(@url, headers: headers)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, handle_exception if @status_code != 200
    end

    # Envia uma solicitação para atualizar o token de acesso.
    #
    # @raise [Salesforce::Error] Se a resposta não tiver um código de status 200 ou 201.
    def refresh
      response = HTTParty.post(@url, headers: headers_basic)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, handle_exception if @status_code != 201 && @status_code != 200
    end

    private

    # Trata exceções levantadas durante as solicitações HTTP.
    #
    # @return [String] A mensagem de erro extraída da resposta JSON.
    def handle_exception
      exception_message = json.dig(0, "message") || json["error_description"] || json.to_s
      raise Salesforce::Error, exception_message
    end

    # Retorna os cabeçalhos HTTP padrão para as solicitações.
    #
    # @return [Hash] Um hash contendo os cabeçalhos HTTP.
    def headers
      {
        Authorization: "Bearer #{@access_token}",
        "Content-Type": "application/json"
      }
    end

    # Retorna os cabeçalhos HTTP básicos para as solicitações autenticadas com credenciais básicas.
    #
    # @return [Hash] Um hash contendo os cabeçalhos HTTP.
    def headers_basic
      {
        Authorization: "Basic",
        "Content-Type": "application/json"
      }
    end

    # Converte o payload fornecido em formato JSON.
    #
    # @param [Hash] kwargs Um hash de argumentos nomeados.
    # @option kwargs [Hash] :payload O payload a ser convertido em JSON.
    #
    # @return [String] O payload convertido em formato JSON.
    def body
      kwargs[:payload].to_json
    end
  end
end
