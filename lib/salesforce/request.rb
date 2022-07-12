# frozen_string_literal: true

module Salesforce
  # Salesforce::Request is a wrapper around Net::HTTP::Post.
  class Request < Salesforce::Base
    attr_reader :json, :status_code
    attr_writer :access_token

    # @param [String] url
    def initialize(**kwargs)
      @url = kwargs[:url]
      raise Salesforce::Error, 'URL is required' if blank? @url
    rescue Salesforce::Error => e
      raise e
    end

    # @param [Hash] payload
    def post(**kwargs)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@access_token}" unless blank? @access_token
      request['Content-Type'] = 'application/json'
      request.body = kwargs[:payload].to_json unless blank? kwargs[:payload]
      responde = http.request(request)

      @json = JSON.parse(responde.body)
      @status_code = responde.code.to_i

      raise Salesforce::Error, @json[0]['message'] if @status_code != 201 && @status_code != 200
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
      responde = http.request(request)

      @json = JSON.parse(responde.body)
      @status_code = responde.code.to_i

      raise Salesforce::Error, @json[0]['message'] if @status_code != 200
    rescue Salesforce::Error => e
      raise e
    end

    def refresh
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = 'Basic'
      request['Content-Type'] = 'application/json'
      responde = http.request(request)

      @json = JSON.parse(responde.body)
      @status_code = responde.code.to_i

      raise Salesforce::Error, @json if @status_code != 201 && @status_code != 200
    rescue Salesforce::Error => e
      raise e
    end
  end
end
