# frozen_string_literal: true

module Salesforce
  # A classe Lead é responsável por gerenciar as operações relacionadas aos leads no Salesforce.
  # Ela permite a inicialização com os parâmetros necessários para autenticação e configuração,
  # e fornece métodos para enviar dados de leads para o Salesforce.
  #
  # @example
  #   lead = Salesforce::Lead.new(
  #     access_token: "seu_access_token",
  #     refresh_token: "seu_refresh_token",
  #     instance_url: "https://sua_instancia.salesforce.com",
  #     issued_at: "timestamp",
  #     client_id: "seu_client_id",
  #     client_secret: "seu_client_secret",
  #     timezone: "seu_fuso_horário",
  #     api_version: "v52.0"
  #   )
  #
  #   response = lead.send(payload: { nome: "John Doe", email: "john.doe@example.com" })
  #
  # @see Salesforce::Request
  class Lead
    attr_reader :fields, :required_fields, :normalized_fields

    # Inicializa uma nova instância com os parâmetros fornecidos.
    #
    # @param [Hash] kwargs Um hash contendo os parâmetros de inicialização.
    # @option kwargs [String] :access_token O token de acesso para autenticação.
    # @option kwargs [String] :refresh_token O token de atualização para renovar o token de acesso.
    # @option kwargs [String] :instance_url A URL da instância do Salesforce.
    # @option kwargs [String] :issued_at O timestamp de quando o token foi emitido.
    # @option kwargs [String] :client_id O ID do cliente, opcional, padrão é Salesforce.client_id.
    # @option kwargs [String] :client_secret O segredo do cliente, opcional, padrão é Salesforce.client_secret.
    # @option kwargs [String] :timezone O fuso horário atual, opcional, padrão é Salesforce.timezone.
    # @option kwargs [String] :api_version A versão da API a ser usada, opcional, padrão é API_VERSION.
    #
    # @raise [Salesforce::Error] Se o token de acesso ou a URL da instância não forem fornecidos.
    def initialize(**kwargs)
      @access_token = kwargs[:access_token]
      @refresh_token = kwargs[:refresh_token]
      @instance_url = kwargs[:instance_url]
      @issued_at = kwargs[:issued_at]
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @current_timezone = kwargs[:timezone] || Salesforce.timezone
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, "Access token is required" if @access_token.blank?
      raise Salesforce::Error, "Instance URL is required" if @instance_url.blank?
    end

    # Envia um payload para o endpoint do Salesforce.
    #
    # @param [Hash] payload O payload a ser enviado.
    #
    # @raise [Salesforce::Error] Se o payload estiver vazio.
    # @raise [Salesforce::Error] Se a resposta do Salesforce contiver um erro.
    #
    # @return [Hash] A resposta JSON do Salesforce.
    def send(payload)
      @payload = payload
      raise Salesforce::Error, "Payload is required" if @payload.blank?

      response = Salesforce::Request.new(url: endpoint_send)
      response.access_token = @access_token
      normalizer
      raise Salesforce::Error, "The payload is in mandatory shipping" if @payload.blank?

      response.post(payload: @payload)
      raise Salesforce::Error, response.json[0]["message"] if response.status_code != 201

      response.json
    end

    # Atualiza o token de acesso usando o token de atualização.
    #
    # @raise [Salesforce::Error] Se o token de atualização não for fornecido.
    #
    # @return [void]
    def refresh_token!
      raise Salesforce::Error, "Refresh token is required" if @refresh_token.blank?

      oauth = Salesforce::OAuthCodeRefreshToken.new(
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: @refresh_token
      )

      oauth.call
      @access_token = oauth.access_token
      @instance_url = oauth.instance_url
      @issued_at = oauth.issued_at
    end

    # Recupera e processa os campos do objeto Lead do Salesforce.
    #
    # @raise [Salesforce::Error] Se a resposta do Salesforce contiver um erro.
    #
    # @return [void]
    def field!
      response = Salesforce::Request.new(url: endpoint_field)
      response.access_token = @access_token
      response.get
      fields = response.json["fields"]
      @fields = {}
      @normalized_fields = {}
      @required_fields = []
      fields.map do |field|
        not_remove_fields = !%w[Name].include?(field["name"])
        remove_fields = %w[FirstName LastName].include?(field["name"])
        createable = field["createable"] == false
        remove_type = %w[reference].include?(field["type"])
        remove_required = field["nillable"] == false && field["type"] != "boolean"
        @fields.merge!({ field["name"] => { "type" => field["type"], "title" => field["label"] } })

        next if (not_remove_fields && createable) || (not_remove_fields && remove_type) || remove_fields

        field_temp = { field["name"] => { "type" => "string", "title" => field["label"] } }
        if %w[multipicklist picklist].include?(field["type"]) && field["picklistValues"].length.positive?
          field_temp[field["name"]].merge!(create_enum(field["picklistValues"]))
        end

        @required_fields.append(field["name"]) if remove_required
        @normalized_fields.merge!(field_temp)
      end
      nil
    end

    private

    # Retorna a URL do endpoint para descrever os campos do objeto Lead no Salesforce.
    #
    # @return [String] A URL do endpoint para descrever os campos do objeto Lead.
    def endpoint_field
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead/describe"
    end

    # Retorna a URL do endpoint para enviar dados ao objeto Lead no Salesforce.
    #
    # @return [String] A URL do endpoint para enviar dados ao objeto Lead.
    def endpoint_send
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead"
    end

    # Normaliza o payload do Lead, removendo campos nulos, convertendo valores e dividindo o campo de nome.
    #
    # @return [void]
    def normalizer
      @payload = JSON.parse(@payload.to_json)
      remove_null_fields
      converter
      split_name_field
    end

    # Converte um objeto em um valor booleano.
    #
    # @param [Object] object O objeto a ser convertido.
    #   - Retorna `true` se o objeto for `true` ou corresponder a uma das strings: "true", "t", "yes", "y", "1", "sim" (case insensitive).
    #   - Retorna `false` se o objeto for `false` ou corresponder a uma das strings: "false", "f", "no", "n", "0", "não", "nao" (case insensitive).
    #   - Retorna `nil` se o objeto não corresponder a nenhum dos valores acima.
    #
    # @return [Boolean, nil] O valor booleano correspondente ou `nil` se não houver correspondência.
    def to_b(object)
      return true if object == true || object =~ (/^(true|t|yes|y|1|sim)$/i)
      return false if object == false || object =~ (/^(false|f|no|n|0|não|nao)$/i)

      nil
    end

    # Remove campos nulos ou em branco do payload do Lead.
    #
    # @return [void]
    def remove_null_fields
      normalized_payload = {}
      @payload.each do |key, value|
        next if value.blank?

        normalized_payload.merge!({ key => value })
      end
      @payload = normalized_payload
    end

    # Divide o campo "Name" do payload em "FirstName" e "LastName".
    #
    # Se o campo "Name" estiver presente e não estiver em branco, ele será dividido em duas partes:
    # "FirstName" e "LastName". Se o "LastName" estiver em branco após a divisão, ele será definido como "Não Informado".
    # O campo original "Name" será removido do payload.
    #
    # @return [void]
    def split_name_field
      full_name = @payload["Name"]
      return if full_name.blank?

      first_name, last_name = full_name.split(" ", 2)
      @payload["FirstName"] = first_name
      @payload["LastName"] = last_name.blank? ? "Não Informado" : last_name
      @payload.delete("Name")
    end

    # Converte os valores do payload do Lead para os tipos apropriados com base nos metadados dos campos.
    #
    # Este método percorre cada par chave-valor no payload e converte o valor para o tipo apropriado
    # com base no tipo definido nos metadados dos campos. Os tipos suportados incluem:
    # - "datetime": Converte para datetime.
    # - "date": Converte para datetime.
    # - "multipicklist": Converte para uma lista de valores.
    # - "picklist": Converte para uma lista de valores.
    # - "currency" e "double": Converte para float.
    # - "int": Converte para inteiro.
    # - "boolean": Converte para booleano.
    # - "reference": Converte para string.
    #
    # Após a conversão, remove campos nulos ou em branco do payload.
    #
    # @return [void]
    def converter
      # TODO: Adicionar todos os tipos de dados suportados na documentação.
      @fields ||= {}

      @payload.each do |key, value|
        type = @fields.dig(key, "type")
        next if type.blank?

        @payload[key] = parse_datetime(value) if type == "datetime"
        @payload[key] = parse_datetime(value) if type == "date"
        @payload[key] = parse_multipicklist(value) if type == "multipicklist"
        @payload[key] = parse_multipicklist(value) if type == "picklist"
        @payload[key] = value.to_f if %w[currency double].include?(type)
        @payload[key] = value.to_i if type == "int"
        @payload[key] = to_b(value) if type == "boolean"
        @payload[key] = value.to_s if type == "reference"
        # TODO: Adicionar suporte para outros tipos de dados, se necessário.
        # - Address
        # - Lookup(User)
        # - Lookup(Individual)
        # - Lookup(User)
        # - Lookup(User,Group)
      end

      remove_null_fields
    end

    # Converte uma string de data e hora para o formato XML Schema no fuso horário especificado.
    #
    # @param [String] datetime A string de data e hora a ser convertida.
    #   - A string deve estar em um formato que possa ser analisado pelo método `Time.parse`.
    #
    # @return [String] A data e hora convertida para o formato XML Schema no fuso horário especificado.
    def parse_datetime(datetime)
      timezone = @current_timezone || TIMEZONE
      Time.parse(datetime).in_time_zone(timezone).xmlschema.to_s
    end

    # Converte uma string de multipicklist, substituindo vírgulas por ponto e vírgula.
    #
    # @param [String] multipicklist A string de multipicklist a ser convertida.
    #   - A string deve conter valores separados por vírgulas.
    #
    # @return [String] A string de multipicklist com vírgulas substituídas por ponto e vírgula.
    def parse_multipicklist(multipicklist)
      multipicklist.gsub(",", ";").to_s
    end

    # Cria um hash de enumeração a partir de uma lista de valores de picklist.
    #
    # Este método recebe uma lista de valores de picklist e cria um hash que representa uma enumeração.
    # O hash resultante contém as seguintes chaves:
    # - "enum": Uma lista de valores de picklist, incluindo um valor vazio inicial.
    # - "default": O valor padrão do picklist, se houver.
    # - "showCustomVariables": Um booleano que indica se as variáveis personalizadas devem ser exibidas.
    #
    # @param [Array<Hash>] picklistvalues Uma lista de hashes que representam os valores do picklist.
    #   Cada hash deve conter as chaves "value" e "defaultValue".
    #   - "value": O valor do picklist.
    #   - "defaultValue": Um booleano que indica se este é o valor padrão.
    #
    # @return [Hash] Um hash que representa a enumeração do picklist.
    def create_enum(picklistvalues)
      picklist = { "enum" => [""], "default" => "", "showCustomVariables" => true }
      picklistvalues.map do |value|
        picklist["default"] = value["value"] if value["defaultValue"] == true
        picklist["enum"].append(value["value"])
      end
      picklist
    end
  end
end
