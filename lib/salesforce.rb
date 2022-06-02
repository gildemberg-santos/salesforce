# frozen_string_literal: true

require_relative "salesforce/version"
require 'uri'
require 'json'
require 'net/http'

module Salesforce
  class Error < StandardError; end

  class OAuth
    def initialize(client_id, client_secret = nil, username = nil, password = nil, security_token = nil,
                  redirect_uri = nil, api_version = "v37.0")

      @client_id = client_id
      @client_secret = client_secret
      @username = username
      @password = password
      @security_token = security_token
      @redirect_uri = redirect_uri
      @api_version = api_version

      raise Error, "Client ID is required" if blank? client_id
    rescue Salesforce::Error => e
      raise e
    end

    def get_token
      uri = URI.parse(oauth_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      JSON.parse(response.body)&.dig("access_token")
    rescue Salesforce::Error => e
      raise e
    end

    def authorize_url
      raise Error, "Redirect URI is required" if blank? @redirect_uri

      "https://login.salesforce.com/services/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
    rescue Salesforce::Error => e
      raise e
    end

    private

    def oauth_url
      raise Error, "Client secret is required" if blank? @client_secret
      raise Error, "Username is required" if blank? @username
      raise Error, "Password is required" if blank? @password
      raise Error, "Security token is required" if blank? @security_token

      "https://login.salesforce.com/services/oauth2/token?grant_type=password&client_id=#{@client_id}&client_secret=#{@client_secret}&username=#{@username}&password=#{@password}#{@security_token}"
    rescue Salesforce::Error => e
      raise e
    end

    def blank?(value)
      value.nil? || value.empty? || value.to_s.strip.empty?
    end
  end
end
