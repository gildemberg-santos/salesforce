# frozen_string_literal: true

# O módulo Salesforce fornece métodos para configurar e acessar as credenciais necessárias para autenticação na API do Salesforce.
# Este módulo permite definir e obter valores como `client_id`, `client_secret`, `redirect_uri`, `username`, `password` e `security_token`.
#
# @example
#   Salesforce.client_id = "seu_client_id"
#   puts Salesforce.client_id # => "seu_client_id"
#
# @see Salesforce::OAuth
module Salesforce
  @client_id = nil
  @client_secret = nil
  @redirect_uri = nil
  @username = nil
  @password = nil
  @security_token = nil

  # Define o ID do cliente.
  #
  # @param [String] value O novo valor para o ID do cliente.
  def self.client_id=(value)
    @client_id ||= value
  end

  # Retorna o ID do cliente.
  #
  # @return [String] O ID do cliente.
  def self.client_id
    @client_id
  end

  # Define o segredo do cliente.
  #
  # @param [String] value O novo valor para o segredo do cliente.
  def self.client_secret=(value)
    @client_secret ||= value
  end

  # Retorna o segredo do cliente.
  #
  # @return [String] O segredo do cliente.
  def self.client_secret
    @client_secret
  end

  # Define o URI de redirecionamento.
  #
  # @param [String] value O novo valor para o URI de redirecionamento.
  def self.redirect_uri=(value)
    @redirect_uri ||= value
  end

  # Retorna o URI de redirecionamento.
  #
  # @return [String] O URI de redirecionamento.
  def self.redirect_uri
    @redirect_uri
  end

  # Define o nome de usuário.
  #
  # @param [String] value O novo valor para o nome de usuário.
  def self.username=(value)
    @username ||= value
  end

  # Retorna o nome de usuário.
  #
  # @return [String] O nome de usuário.
  def self.username
    @username
  end

  # Define a senha.
  #
  # @param [String] value O novo valor para a senha.
  def self.password=(value)
    @password ||= value
  end

  # Retorna a senha.
  #
  # @return [String] A senha.
  def self.password
    @password
  end

  # Define o token de segurança.
  #
  # @param [String] value O novo valor para o token de segurança.
  def self.security_token=(value)
    @security_token ||= value
  end

  # Retorna o token de segurança.
  #
  # @return [String] O token de segurança.
  def self.security_token
    @security_token
  end
end
