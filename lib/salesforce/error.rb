# frozen_string_literal: true

# O módulo Salesforce fornece classes e métodos para interagir com a API do Salesforce.
# Ele inclui a classe `Error`, que é a classe base para erros específicos do Salesforce.
#
# @example
#   begin
#     # código que pode gerar um erro
#   rescue Salesforce::Error => e
#     puts "Ocorreu um erro no Salesforce: #{e.message}"
#   end
#
# @see Salesforce::OAuth
module Salesforce
  # Salesforce::Error é a classe base para erros específicos do Salesforce.
  # Ela herda de StandardError e adiciona funcionalidades de logging quando o modo de depuração está ativado.
  #
  # @attr_reader [Array] args Os argumentos passados para o erro.
  class Error < StandardError
    # Inicializa uma nova instância da classe Error.
    # Se o modo de depuração estiver ativado, cria um diretório de logs e registra a mensagem de erro.
    #
    # @param [Array] args Os argumentos passados para o erro.
    def initialize(*args)
      super(*args)
      return unless Salesforce.debug?

      Dir.mkdir("log")

      log = Logger.new("log/salesforce.log", 0, 100 * 1024 * 1024)
      log.debug(args)
    end
  end
end
