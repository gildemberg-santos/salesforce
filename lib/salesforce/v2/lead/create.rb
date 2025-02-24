module Salesforce
  module V2
    # This module defines the Lead namespace.
    module Lead
      # Custom error class for invalid payloads.
      class InvalidPayload < StandardError; end

      # This class handles the creation of a Lead.
      # It inherits from Micro::Case::Safe to ensure safe execution of the use case.
      class Create < ::Micro::Case::Safe
        # Attributes expected by the use case.
        attributes :payload

        # Main method to execute the use case.
        # It validates and normalizes the payload, then returns a success or failure result.
        #
        # @return [Micro::Case::Result] The result of the use case execution.
        def call!
          validate!
          normalize_payload
          Success result: { message: "Lead created successfully!", payload: payload }
        rescue InvalidPayload
          Failure(:invalid_payload)
        end

        private

        # Validates the payload.
        # Raises an InvalidPayload error if the payload is blank.
        #
        # @raise [InvalidPayload] If the payload is blank.
        def validate!
          raise InvalidPayload if payload.blank?
        end

        # Normalizes the payload by symbolizing keys and removing blank values.
        #
        # @return [Hash] The normalized payload.
        def normalize_payload
          @payload.deep_symbolize_keys!
          unless @payload[:Name].blank?
            @payload[:FirstName], @payload[:LastName] = @payload.delete(:Name).to_s.split(" ", 2).tap do |_, last|
              last.replace("Not Provided") if last.blank?
            end
          end
          @payload.reject! { |_, v| v.blank? }
        end
      end
    end
  end
end
