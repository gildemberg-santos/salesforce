# frozen_string_literal: true

module Salesforce
  # Salesforce::Lead is Salesforce lead class.
  class Lead < Salesforce::Base
    attr_reader :fields, :required_fields, :normalized_fields

    # @param [String] access_token
    # @param [String] refresh_token
    # @param [String] instance_url
    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] timezone
    # @param [String] api_version
    def initialize(**kwargs)
      @access_token = kwargs[:access_token]
      @refresh_token = kwargs[:refresh_token]
      @instance_url = kwargs[:instance_url]
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @current_timezone = kwargs[:timezone] || Salesforce.timezone
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, 'Access token is required' if blank? @access_token
      raise Salesforce::Error, 'Instance URL is required' if blank? @instance_url

      refresh_token! if kwargs[:refresh_token_call].present?
      field!
    rescue Salesforce::Error => e
      raise e
    end

    # @param [Hash] payload
    def send(payload)
      raise Salesforce::Error, 'Payload is required' if blank? payload

      response = Salesforce::Request.new(url: endpoint_send)
      response.access_token = @access_token
      payload = normalizer(payload)
      raise Salesforce::Error, 'The payload is in mandatory shipping' if blank? payload

      response.post(payload: payload)
      raise Salesforce::Error, response.json[0]['message'] if response.status_code != 201

      response.json
    rescue Salesforce::Error => e
      raise e
    end

    private

    def refresh_token!
      raise Salesforce::Error, 'Refresh token is required' if blank? @refresh_token

      oauth = Salesforce::OAuthCodeRefreshToken.new(
        client_id: @client_id,
        client_secret: @client_secret,
        refresh_token: @refresh_token
      )

      oauth.call
      @access_token = oauth.access_token
      @instance_url = oauth.instance_url
    end

    def field!
      response = Salesforce::Request.new(url: endpoint_field)
      response.access_token = @access_token
      response.get
      json = response.json
      fields = json&.dig('fields')
      @fields = {}
      @normalized_fields = {}
      @required_fields = []
      fields.map do |field|
        not_remove_fields = !%w[Name].include?(field['name'])
        remove_fields = %w[FirstName LastName].include?(field['name'])
        createable = field['createable'] == false
        remove_type = %w[boolean reference].include?(field['type'])
        next if (not_remove_fields && createable) || (not_remove_fields && remove_type) || remove_fields

        field_temp = { field['name'] => { 'type' => 'string', 'title' => field['label'] } }
        if %w[multipicklist picklist].include?(field["type"]) and field['picklistValues'].length.positive?
          field_temp[field['name']].merge!(create_enum(field['picklistValues']))
        end

        @required_fields.append(field['name']) if field['nillable'] == false
        @normalized_fields.merge!(field_temp)
        @fields.merge!({ field['name'] => { 'type' => field['type'], 'title' => field['label'] } })
      end
      nil
    rescue Salesforce::Error => e
      raise e
    end

    def endpoint_field
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead/describe"
    end

    def endpoint_send
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead"
    end

    def normalizer(payload)
      payload = JSON.parse(payload.to_json)
      payload = remove_null_fields(payload)
      payload = split_name_field(payload)
      converter(payload)
    rescue Salesforce::Error => e
      raise e
    end

    def to_b(object)
      !!object
    rescue Salesforce::Error => e
      raise e
    end

    def remove_null_fields(payload)
      normalized_payload = {}
      payload.each do |key, value|
        next if blank?(value)

        normalized_payload.merge!({ key => value })
      end
      normalized_payload
    rescue Salesforce::Error => e
      raise e
    end

    def split_name_field(payload)
      full_name = payload['Name']
      return payload if blank?(full_name)

      first_name, last_name = full_name.split(' ')
      payload['FirstName'] = first_name
      payload['LastName'] = last_name
      payload.delete('Name')
      payload
    rescue Salesforce::Error => e
      raise e
    end

    def converter(payload)
      payload.each do |key, value|
        type = @fields[key]['type']
        payload[key] = parse_datetime(value) if type == 'datetime'
        payload[key] = parse_datetime(value) if type == 'date'
        payload[key] = parse_multipicklist(value) if type == 'multipicklist'
        payload[key] = value.to_f if %w[currency double].include?(type)
        payload[key] = value.to_i if type == 'int'
        payload[key] = to_b(value) if type == 'boolean'
        payload[key] = value.to_s if type == 'reference'
      end
      payload
    rescue Salesforce::Error => e
      raise e
    end

    def parse_datetime(datetime)
      timezone = @current_timezone || TIMEZONE
      Time.parse(datetime).in_time_zone(timezone).xmlschema.to_s
    rescue Salesforce::Error => e
      raise e
    end

    def parse_multipicklist(multipicklist)
      multipicklist.gsub(',', ';').to_s
    rescue Salesforce::Error => e
      raise e
    end

    def create_enum(picklistValues)
      picklist = { 'enum' => [], 'default' => nil, 'showCustomVariables' => false }
      picklistValues.map do |value|
        picklist['default'] = value['value'] if value['defaultValue'] == true
        picklist['enum'].append(value['value'])
      end
      picklist
    end
  end
end
