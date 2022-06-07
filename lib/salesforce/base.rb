# frozen_string_literal: true

module Salesforce
  # Salesforce::Base is base class for Salesforce classes.
  class Base
    def blank?(value)
      value.nil? || value.to_s.empty? || value.to_s.strip.empty?
    end
  end
end
