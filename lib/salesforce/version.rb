# frozen_string_literal: true

module Salesforce
  VERSION = '0.1.16'
  API_VERSION = 'v54.0'
  TIMEZONE = 'America/Sao_Paulo'

  @debug = false

  def self.debug=(value)
    @debug = value
  end

  def self.debug?
    @debug
  end
end
