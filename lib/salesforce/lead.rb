# frozen_string_literal: true

module Salesforce
  # Salesforce::Lead is Salesforce lead class.
  class Lead < Salesforce::Base
    attr_reader :fields, :required_fields, :normalized_fields

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
      payload = normalizer(payload)
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
      @normalized_fields = {}
      @required_fields = []
      fields.map do |field|
        not_remove_fields = !%w[Name OwnerId Birthday__c].include?(field['name'])
        createable = field['createable'] == false
        remove_type = %w[boolean reference].include?(field['type'])
        next if (not_remove_fields && createable) || (not_remove_fields && remove_type)

        @normalized_fields.merge!({ field['name'] => { 'type' => 'string', 'title' => field['label'] } })
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
      payload = mandatory_output_fields(payload)
      converter(payload)
    end

    def to_b(object)
      !!object
    end

    def remove_null_fields(payload)
      normalized_payload = {}
      payload.each do |key, value|
        next if value.nil?

        normalized_payload.merge!({ key => value })
      end
      normalized_payload
    end

    def split_name_field(payload)
      full_name = payload['Name']
      return payload if full_name.nil?

      first_name, last_name = full_name.split(' ')
      payload['FirstName'] = first_name
      payload['LastName'] = last_name
      payload.delete('Name')
      payload
    end

    def mandatory_output_fields(payload)
      last_name = payload['LastName']
      company = payload['Company']
      payload['LastName'] = last_name.nil? ? 'data not found' : last_name
      payload['Company'] = company.nil? ? 'data not found' : company
      payload
    end

    def converter(payload)
      payload.each do |key, value|
        type = @fields[key]['type']
        payload[key] = Time.parse(value).strftime('%Y-%m-%dT%H:%M:%S%Z').to_s if type == 'datetime'
        payload[key] = Time.parse(value).strftime('%Y-%m-%d').to_s if type == 'date'
        payload[key] = value.gsub(',', ';') if type == 'multipicklist'
        payload[key] = value.to_f if %w[currency double].include?(type)
        payload[key] = value.to_i if type == 'int'
        payload[key] = to_b(value) if type == 'boolean'
      end
      payload
    end
  end
end
