# frozen_string_literal: true

# O módulo Salesforce fornece métodos para gerenciar o fuso horário padrão usado nas operações com o Salesforce.
# Ele permite definir e obter o fuso horário atual.
#
# @example
#   Salesforce.timezone = "America/New_York"
#   puts Salesforce.timezone  # => "America/New_York"
module Salesforce
  @timezone = "America/Sao_Paulo"

  # Define o fuso horário padrão.
  #
  # @param [String] value O novo fuso horário a ser definido.
  def self.timezone=(value)
    @timezone = value
  end

  # Retorna o fuso horário padrão atual.
  #
  # @return [String] O fuso horário atual.
  def self.timezone
    @timezone
  end
end
