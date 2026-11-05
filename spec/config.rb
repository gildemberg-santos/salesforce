# frozen_string_literal: true

require "yaml"

# Carrega as credenciais usadas nos testes.
#
# Ordem de prioridade:
#   1. spec/config.yaml (ignorado pelo Git) — use para regravar os cassettes contra uma org real;
#   2. variáveis de ambiente SALESFORCE_<CHAVE> (ex.: SALESFORCE_CLIENT_ID);
#   3. valores fictícios, suficientes para rodar a suíte a partir dos cassettes do VCR.
#
# Os cassettes guardam apenas placeholders (<CLIENT_ID>, <ACCESS_TOKEN>...). O VCR troca esses
# placeholders pelos valores abaixo na reprodução, então nenhum segredo real fica versionado.
CONFIG_KEYS = %w[
  client_id client_secret username password security_token redirect_uri timezone
  api_version code refresh_token access_token instance_url
].freeze

CONFIG_DEFAULTS = {
  "client_id" => "test-client-id",
  "client_secret" => "test-client-secret",
  "username" => "user@example.com",
  "password" => "test-password",
  "security_token" => "test-security-token",
  "redirect_uri" => "https://example.com/callback",
  "timezone" => "America/Sao_Paulo",
  "api_version" => "v54.0",
  "code" => "test-code",
  "refresh_token" => "test-refresh-token",
  "access_token" => "test-access-token",
  "instance_url" => "https://example.my.salesforce.com"
}.freeze

config_path = File.join(__dir__, "config.yaml")
config_file = File.exist?(config_path) ? (YAML.load_file(config_path) || {}) : {}

config_values = CONFIG_KEYS.to_h do |key|
  value = config_file[key].to_s
  value = ENV.fetch("SALESFORCE_#{key.upcase}", "") if value.empty?
  value = CONFIG_DEFAULTS.fetch(key) if value.empty?
  [key, value]
end

CONFIG_SPEC = Struct.new(*CONFIG_KEYS.map(&:to_sym)).new(*config_values.values)

CLIENT_ID = CONFIG_SPEC.client_id
CLIENT_SECRET = CONFIG_SPEC.client_secret
USERNAME = CONFIG_SPEC.username
PASSWORD = CONFIG_SPEC.password
SECURITY_TOKEN = CONFIG_SPEC.security_token
REDIRECT_URI = CONFIG_SPEC.redirect_uri
TIMEZONE = CONFIG_SPEC.timezone
API_VERSION = CONFIG_SPEC.api_version
CODE = CONFIG_SPEC.code
REFRESH_TOKEN = CONFIG_SPEC.refresh_token
ACCESS_TOKEN = CONFIG_SPEC.access_token
INSTANCE_URL = CONFIG_SPEC.instance_url
