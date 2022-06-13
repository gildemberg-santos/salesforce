# frozen_string_literal: true

module Salesforce
  # Salesforce::Lead is Salesforce lead class.
  class Lead < Salesforce::Base
    attr_reader :fields, :required_fields

    def initialize(access_token, instance_url, api_version = API_VERSION)
      @access_token = access_token
      @instance_url = instance_url
      @api_version = api_version

      raise Salesforce::Error, 'Access token is required' if blank? @access_token
      raise Salesforce::Error, 'Instance URL is required' if blank? @instance_url

      field!
    rescue Salesforce::Error => e
      raise e
    end

    def send(payload)
      response = Salesforce::Request.new(endpoint_send)
      response.access_token = @access_token
      response.post(payload)
      raise Salesforce::Error, response.json[0]['message'] if response.status_code != 201

      response.json
    rescue Salesforce::Error => e
      raise e
    end

    private

    def field!
      response = Salesforce::Request.new(endpoint_field)
      response.access_token = @access_token
      response.get
      json = response.json
      fields = json&.dig('fields')
      @fields = {}
      @required_fields = %w[Company LastName]
      fields.map do |field|
        next unless field['createable']

        type = field['type']
        type_string = %w[textarea picklist phone email url]
        type_number = %w[double currency]
        type_interger = %w[int reference]
        type = 'string' if type_string.include? type
        type = 'number' if type_number.include? type
        type = 'integer' if type_interger.include? type
        @fields.merge!({ field['name'] => { 'type' => type, 'title' => field['label'] } })
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
  end
end
