# frozen_string_literal: true

module Salesforce
  # Salesforce::Lead is Salesforce lead class.
  class Lead < Salesforce::Base
    attr_reader :fields
    attr_reader :required_fields

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
      @required_fields = ["Company", "LastName"]
      fields.map do |field|
        @fields.merge!({field['name'] =>{"type" => "string", "title" => field['label']}})
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
