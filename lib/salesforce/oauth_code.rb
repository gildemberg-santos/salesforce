# frozen_string_literal: true

module Salesforce
  # Salesforce::OauthCode is class for Salesforce OAuth code.
  class OAuthCode < Salesforce::OAuth
    attr_reader :authorize, :refresh_token
    attr_accessor :code

    # @param [String] client_id
    # @param [String] client_secret
    # @param [String] redirect_uri
    # @param [String] api_version
    def initialize(**kwargs)
      @client_id = kwargs[:client_id] || Salesforce.client_id
      @client_secret = kwargs[:client_secret] || Salesforce.client_secret
      @redirect_uri = kwargs[:redirect_uri] || Salesforce.redirect_uri
      @api_version = kwargs[:api_version] || API_VERSION

      raise Salesforce::Error, "Client ID is required" if @client_id.blank?
      raise Salesforce::Error, "Client secret is required" if @client_secret.blank?
      raise Salesforce::Error, "Redirect URI is required" if @redirect_uri.blank?
      raise Salesforce::Error, "API version is required" if @api_version.blank?

      endpoint_authorize
    end

    def call
      response = Salesforce::Request.new(url: endpoint)
      response.post
      @access_token = response.json["access_token"]
      @refresh_token = response.json["refresh_token"]
      @instance_url = response.json["instance_url"]
      @issued_at = response.json["issued_at"]
      nil
    end

    private

    def endpoint_authorize
      @authorize = "#{host}authorize?#{endpoint_authorize_query}"
    end

    def endpoint_authorize_query
      URI.encode_www_form(
        {
          response_type: "code",
          client_id: @client_id,
          redirect_uri: @redirect_uri
        }
      )
    end

    def endpoint
      raise Salesforce::Error, "Code is required" if @code.blank?

      "#{host}token?#{endpoint_query}"
    end

    def endpoint_query
      URI.encode_www_form(
        {
          grant_type: "authorization_code",
          client_id: @client_id,
          client_secret: @client_secret,
          redirect_uri: @redirect_uri,
          code: @code,
          format: "json"
        }
      )
    end
  end
end
