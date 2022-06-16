# frozen_string_literal: true

module Salesforce
  # Salesforce::Error is base class for Salesforce errors.
  class Error < StandardError
    def initialize(*args)
      super(*args)
      if Salesforce.debug?
        Dir.mkdir('log') unless Dir.exist?('log')
        log = Logger.new('log/salesforce.log', 0, 100 * 1024 * 1024)
        log.debug(args)
      end
    end
  end
end
