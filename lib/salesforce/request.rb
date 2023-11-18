# frozen_string_literal: true

module Salesforce
  # Salesforce::Request is a wrapper around Net::HTTP::Post.
  class Request
    attr_reader :json, :status_code
    attr_writer :access_token

    # @param [String] url
    def initialize(**kwargs)
      @url = kwargs[:url]
      raise Salesforce::Error, "URL is required" if @url.blank?
    end

    # @param [Hash] payload
    def post(**kwargs)
      response = HTTParty.post(@url, headers: headers, body: kwargs[:payload].to_json)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, @json[0]["message"] if @status_code != 201 && @status_code != 200
    end

    def get
      response = HTTParty.get(@url, headers: headers)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, @json[0]["message"] if @status_code != 200
    end

    def refresh
      response = HTTParty.post(@url, headers: headers_basic)
      @json = response
      @status_code = response.code
      raise Salesforce::Error, @json if @status_code != 201 && @status_code != 200
    end

    private

    def headers
      {
        Authorization: "Bearer #{@access_token}",
        "Content-Type": "application/json"
      }
    end

    def headers_basic
      {
        Authorization: "Basic",
        "Content-Type": "application/json"
      }
    end

    def body
      kwargs[:payload].to_json
    end
  end
end
