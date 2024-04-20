module Salesforce
  module V2
    module Lead
      class InvalidPayload < StandardError; end

      class Create < ::Micro::Case::Safe
        attributes :payload

        def call!
          validate!
          normalize_payload
          Success result: { message: "Lead created successfully!", payload: payload }
        rescue InvalidPayload
          Failure(:invalid_payload)
        end

        private

        def validate!
          raise InvalidPayload if payload.blank?
        end

        def normalize_payload
          @payload.deep_symbolize_keys!
          @payload.reject! { |_, v| v.blank? }
        end
      end
    end
  end
end
