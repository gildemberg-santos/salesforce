# frozen_string_literal: true

module Salesforce
  @timezone = "America/Sao_Paulo"

  def self.timezone=(value)
    @timezone = value
  end

  def self.timezone
    @timezone
  end
end
