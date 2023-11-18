# frozen_string_literal: true

config_yml = YAML.load_file(File.join("./spec", "config.yaml"))
CLIENT_ID = config_yml["client_id"]
CLIENT_SECRET = config_yml["client_secret"]
USERNAME = config_yml["username"]
PASSWORD = config_yml["password"]
SECURITY_TOKEN = config_yml["security_token"]
REDIRECT_URI = config_yml["redirect_uri"]
TIMEZONE = config_yml["timezone"]
API_VERSION = config_yml["api_version"]
CODE = config_yml["code"]
REFRESH_TOKEN = config_yml["refresh_token"]
ACCESS_TOKEN = config_yml["access_token"]
INSTANCE_URL = config_yml["instance_url"]
DEBUG = config_yml["debug"]
