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

      # TODO: Validar o coodigo de retorno da API
      def post
        response = HTTParty.post(url, headers: headers, body: body)
        handle_exception(:indefinied_message, response[0]["message"]) unless [201, 200].include? response.code

        response
      end

      def get
        response = HTTParty.get(url, headers: headers)
        handle_exception(:indefinied_message, response[0]["message"]) unless response.code == 200

        response
      end

      # TODO: Validar o retorno de erros do refresh da API
      def refresh
        response = HTTParty.post(url, headers: headers)
        handle_exception(:indefinied_message, response) unless [201, 200].include? response.code

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
        return handle_exception(:invalid_token) if options[:token].nil?
        return handle_exception(:indefinied_method) if options[:method].nil?
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
    end
  end
end
