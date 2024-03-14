# frozen_string_literal: true

module Salesforce
  # Salesforce::OAuthCodeRefreshToken is class for Salesforce OAuth code.
  class OAuthCodeRefreshToken < Salesforce::OAuth
    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] refresh_token
    # @param [String] api_version
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

    def endpoint
      "#{host}token?#{endpoint_query}"
    end

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
