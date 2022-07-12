# frozen_string_literal: true

module Salesforce
  @client_id = nil
  @client_secret = nil
  @redirect_uri = nil
  @username = nil
  @password = nil
  @security_token = nil

  def self.client_id=(value)
    @client_id ||= value
  end

  def self.client_id
    @client_id
  end

  def self.client_secret=(value)
    @client_secret ||= value
  end

  def self.client_secret
    @client_secret
  end

  def self.redirect_uri=(value)
    @redirect_uri ||= value
  end

  def self.redirect_uri
    @redirect_uri
  end

  def self.username=(value)
    @username ||= value
  end

  def self.username
    @username
  end

  def self.password=(value)
    @password ||= value
  end

  def self.password
    @password
  end

  def self.security_token=(value)
    @security_token ||= value
  end

  def self.security_token
    @security_token
  end
end
