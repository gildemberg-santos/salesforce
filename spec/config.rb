# frozen_string_literal: true

require 'yaml'
require 'uri'
require 'json'
require 'net/http'
require 'active_support/time'
require 'logger'
require 'openssl'

require 'salesforce/debug'
require 'salesforce/timezone'
require 'salesforce/credentials'
require 'salesforce/error'
require 'salesforce/version'
require 'salesforce/request'
require 'salesforce/oauth'
require 'salesforce/oauth_code'
require 'salesforce/oauth_code_refresh_token'
require 'salesforce/lead'

config_yml = YAML.load_file(File.join('./spec', 'config.yaml'))
CLIENT_ID = config_yml['client_id']
CLIENT_SECRET = config_yml['client_secret']
USERNAME = config_yml['username']
PASSWORD = config_yml['password']
SECURITY_TOKEN = config_yml['security_token']
REDIRECT_URI = config_yml['redirect_uri']
TIMEZONE = config_yml['timezone']
API_VERSION = config_yml['api_version']
CODE = config_yml['code']
REFRESH_TOKEN = config_yml['refresh_token']
ACCESS_TOKEN = config_yml['access_token']
INSTANCE_URL = config_yml['instance_url']
DEBUG = config_yml['debug']
