require 'yaml'
require 'uri'
require 'json'
require 'net/http'
require 'salesforce/base'
require 'salesforce/error'
require 'salesforce/request'
require 'salesforce/oauth'
require 'salesforce/oauth_code'
require 'salesforce/lead'

config_yml = YAML.load_file(File.join('./spec', 'config.yaml'))
CLIENT_ID = config_yml['client_id']
CLIENT_SECRET = config_yml['client_secret']
USERNAME = config_yml['username']
PASSWORD = config_yml['password']
SECURITY_TOKEN = config_yml['security_token']
REDIRECT_URI = config_yml['redirect_uri']
API_VERSION = config_yml['api_version']
CODE = config_yml['code']