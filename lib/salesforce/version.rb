# frozen_string_literal: true

# O módulo Salesforce fornece constantes e configurações globais para a integração com a API do Salesforce.
# Ele define a versão da biblioteca, a versão da API do Salesforce e o fuso horário padrão.
#
# @example
#   puts Salesforce::VERSION       # => "0.1.25"
#   puts Salesforce::API_VERSION   # => "v54.0"
#   puts Salesforce::TIMEZONE      # => "America/Sao_Paulo"
module Salesforce
  # A versão atual da biblioteca Salesforce.
  VERSION = "0.1.25"

  # A versão da API do Salesforce a ser usada.
  API_VERSION = "v54.0"

  # O fuso horário padrão para operações com o Salesforce.
  TIMEZONE = "America/Sao_Paulo"
end
