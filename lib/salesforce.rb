# frozen_string_literal: true

require_relative "salesforce/version"
require 'uri'
require 'json'
require 'net/http'

module Salesforce
  class Error < StandardError; end

  class OAuth
    def initialize(client_id, client_secret, username, password, security_token,
                   api_version = "v37.0")
      @client_id = client_id
      @client_secret = client_secret
      @username = username
      @password = password
      @security_token = security_token
      @api_version = api_version
    end

    def get_token
      uri = URI.parse(oauth_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      JSON.parse(response.body)&.dig("access_token")
    end

    private

    def oauth_url
      "https://login.salesforce.com/services/oauth2/token?grant_type=password&client_id=#{@client_id}&client_secret=#{@client_secret}&username=#{@username}&password=#{@password}#{@security_token}"
    end
  end
end
