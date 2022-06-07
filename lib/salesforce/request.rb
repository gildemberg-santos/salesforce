# frozen_string_literal: true

module Salesforce
  # Salesforce::Request is a wrapper around Net::HTTP::Post.
  class Request < Salesforce::Base
    attr_reader :json, :status_code
    attr_writer :access_token

    def initialize(url)
      @url = url
    end

    def post(payload = nil)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@access_token}" unless blank? @access_token
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json unless blank? payload
      @json = JSON.parse(http.request(request).body)
      @status_code = http.request(request).code
    rescue Salesforce::Error => e
      raise e
    end

    def get
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@access_token}" unless blank? @access_token
      request['Content-Type'] = 'application/json'
      @json = JSON.parse(http.request(request).body)
      @status_code = http.request(request).code
    rescue Salesforce::Error => e
      raise e
    end
  end
end
