# frozen_string_literal: true

module Salesforce
  module V2
    class Request < Micro::Case::Safe
      attributes :url, :options

      def call!
        valid!

        Success(result: { response: request })
      end

      private

      def request
        send(options[:method])
      end

      def post
        response = HTTParty.post(url, headers: headers, body: body)
        unless [201, 200].include? response.code
          handle_exception(:indefinied_message, handle_exception_message(response))
        end

        response
      end

      def get
        response = HTTParty.get(url, headers: headers)
        handle_exception(:indefinied_message, handle_exception_message(response)) unless response.code == 200

        response
      end

      def headers
        {
          Authorization: options[:token].nil? ? "Basic" : "Bearer #{options[:token]}",
          "Content-Type": "application/json"
        }
      end

      def body
        options[:payload]&.to_json
      end

      def valid!
        return handle_exception(:invalid_url) if url.nil?
        return handle_exception(:invalid_token) if options[:token].nil? && options[:method] != :refresh

        handle_exception(:indefinied_method) if options[:method].nil?
      end

      def handle_exception_message(_response)
        json.dig(0, "message") || json["error_description"] || json.to_s
      end

      def handle_exception(key = nil, exception_message = nil)
        message = {
          invalid_token: "Salesforce token is not valid",
          indefinied_method: "Salesforce method is not valid",
          invalid_url: "Salesforce url is not valid",
          indefinied_message: exception_message
        }

        raise Salesforce::Error, message[key] unless message[key].nil?
      end

      # NOTE: Not send a header with token
      alias refresh post
    end
  end
end
