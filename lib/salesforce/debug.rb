# frozen_string_literal: true

# O módulo Salesforce fornece classes e métodos para interagir com a API do Salesforce.
# Este arquivo define métodos para habilitar ou desabilitar o modo de depuração.
#
# @example
#   Salesforce.debug = true
#   puts Salesforce.debug? # => true
#
# @see Salesforce::Error
module Salesforce
  @debug = false

  # Define o valor do modo de depuração.
  #
  # @param [Boolean] value O novo valor para o modo de depuração.
  def self.debug=(value)
    @debug = value
  end

  # Retorna o valor atual do modo de depuração.
  #
  # @return [Boolean] O valor atual do modo de depuração.
  def self.debug?
    @debug
  end
end
