# frozen_string_literal: true

module Salesforce
  # Salesforce::OAuth is class for Salesforce OAuth.
  class OAuth < Salesforce::Base
    attr_reader :access_token, :instance_url

    def initialize(client_id, client_secret, username, password, security_token, api_version = API_VERSION)
      @client_id = client_id
      @client_secret = client_secret
      @username = username
      @password = password
      @security_token = security_token
      @api_version = api_version

      raise Salesforce::Error, 'Client ID is required' if blank? @client_id
      raise Salesforce::Error, 'Client secret is required' if blank? @client_secret
      raise Salesforce::Error, 'Username is required' if blank? @username
      raise Salesforce::Error, 'Password is required' if blank? @password
      raise Salesforce::Error, 'Security token is required' if blank? @security_token
      raise Salesforce::Error, 'API version is required' if blank? @api_version
    rescue Salesforce::Error => e
      raise e
    end

    def call
      response = Salesforce::Request.new(endpoint)
      response.post
      json = response.json
      @access_token = json&.dig('access_token')
      @instance_url = json&.dig('instance_url')
      nil
    rescue Salesforce::Error => e
      raise e
    end

    private

    def endpoint
      "#{host}token?grant_type=password&client_id=#{@client_id}&client_secret=#{@client_secret}&username=#{@username}&password=#{@password}#{@security_token}"
    rescue Salesforce::Error => e
      raise e
    end

    def host
      'https://login.salesforce.com/services/oauth2/'
    end
  end
end
