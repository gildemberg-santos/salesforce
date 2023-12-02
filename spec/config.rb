# frozen_string_literal: true

unless File.exist?(File.join("./spec", "config.yaml"))
  puts "Config file not found, please create a config.yaml file in the spec folder."
  exit
end
config_yml = YAML.load_file(File.join("./spec", "config.yaml"))
CONFIG_SPEC = Struct.new(*(key = config_yml.keys.map(&:to_sym))).new(*config_yml.values_at(*key))

# TODO: Refactor this code
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
DEBUG = CONFIG_SPEC.debug
