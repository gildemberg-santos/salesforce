# frozen_string_literal: true

require 'salesforce/error'
require 'uri'
require 'json'
require 'net/http'

module Salesforce
  class Requests
    attr_reader :json, :status_code

    def initialize(url)
      @url = url
    rescue Salesforce::Error => e
      raise e
    end

    def post(_payload = nil)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      @json = JSON.parse(http.request(request).body)
      @status_code = http.request(request).code
    rescue Salesforce::Error => e
      raise e
    end
  end
end
