# frozen_string_literal: true

module Salesforce
  @debug = false

  def self.debug=(value)
    @debug = value
  end

  def self.debug?
    @debug
  end
end
