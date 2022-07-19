# frozen_string_literal: true

module Salesforce
  # Salesforce::OAuthCodeRefreshToken is class for Salesforce OAuth code.
  class OAuthCodeRefreshToken < Salesforce::OAuth
    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] refresh_token
    # @param [String] api_version
    def initialize(**kwargs)
      @client_id ||= kwargs[:client_id] || Salesforce.client_id
      @client_secret ||= kwargs[:client_secret] || Salesforce.client_secret
      @refresh_token ||= kwargs[:refresh_token]
      @api_version ||= kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, 'Client ID is required' if blank? @client_id
      raise Salesforce::Error, 'Client secret is required' if blank? @client_secret
      raise Salesforce::Error, 'Refresh token is required' if blank? @refresh_token
      raise Salesforce::Error, 'API version is required' if blank? @api_version
    rescue Salesforce::Error => e
      raise e
    end

    def call
      response = Salesforce::Request.new(url: endpoint)
      response.refresh
      json = response.json
      @access_token = json&.dig('access_token')
      @instance_url = json&.dig('instance_url')
      @issued_at = json&.dig('issued_at')
      nil
    rescue Salesforce::Error => e
      raise e
    end

    private

    def endpoint
      "#{host}token?grant_type=refresh_token&client_id=#{@client_id}&client_secret=#{@client_secret}&refresh_token=#{@refresh_token}"
    rescue Salesforce::Error => e
      raise e
    end
  end
end
