# frozen_string_literal: true

module Salesforce
  # This module defines the V2 namespace for Salesforce API requests.
  module V2
    # The Request class is responsible for making HTTP requests to the Salesforce API.
    # It inherits from Micro::Case::Safe to ensure safe execution of the request logic.
    class Request < Micro::Case::Safe
      attributes :url, :options

      # Attributes:
      # @param url [String] the URL to which the request is sent.
      # @param options [Hash] the options for the request, including method, token, and payload.

      # Executes the request and returns a success result with the response.
      # @return [Micro::Case::Result] the result of the request execution.
      def call!
        valid!
        Success(result: { response: request })
      end

      private

      # Sends the HTTP request based on the specified method in options.
      # @return [HTTParty::Response] the response from the HTTP request.
      def request
        send(options[:method])
      end

      # Sends a POST request to the specified URL with headers and body.
      # @return [HTTParty::Response] the response from the POST request.
      def post
        response = HTTParty.post(url, headers: headers, body: body)
        unless [201, 200].include? response.code
          handle_exception(:indefinied_message, handle_exception_message(response))
        end
        response
      end

      # Sends a GET request to the specified URL with headers.
      # @return [HTTParty::Response] the response from the GET request.
      def get
        response = HTTParty.get(url, headers: headers)
        handle_exception(:indefinied_message, handle_exception_message(response)) unless response.code == 200
        response
      end

      # Constructs the headers for the HTTP request.
      # @return [Hash] the headers for the request.
      def headers
        {
          Authorization: options[:token].nil? ? "Basic" : "Bearer #{options[:token]}",
          "Content-Type": "application/json"
        }
      end

      # Constructs the body for the HTTP request.
      # @return [String, nil] the JSON-encoded payload for the request.
      def body
        options[:payload]&.to_json
      end

      # Validates the request parameters.
      # Raises an exception if any required parameter is invalid.
      def valid!
        return handle_exception(:invalid_url) if url.nil?
        return handle_exception(:invalid_token) if options[:token].nil? && options[:method] != :refresh

        handle_exception(:indefinied_method) if options[:method].nil?
      end

      # Extracts the error message from the response.
      # @param _response [HTTParty::Response] the response from the HTTP request.
      # @return [String] the extracted error message.
      def handle_exception_message(_response)
        json.dig(0, "message") || json["error_description"] || json.to_s
      end

      # Handles exceptions by raising a Salesforce::Error with the appropriate message.
      # @param key [Symbol, nil] the key for the error message.
      # @param exception_message [String, nil] the custom exception message.
      def handle_exception(key = nil, exception_message = nil)
        message = {
          invalid_token: "Salesforce token is not valid",
          indefinied_method: "Salesforce method is not valid",
          invalid_url: "Salesforce url is not valid",
          indefinied_message: exception_message
        }
        raise Salesforce::Error, message[key] unless message[key].nil?
      end

      # Alias for the post method, used for refreshing without sending a token header.
      alias refresh post
    end
  end
end
