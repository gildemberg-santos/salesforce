# frozen_string_literal: true

require "yaml"
require "uri"
require "json"
require "net/http"
require "active_support/time"
require "logger"
require "openssl"
require "httparty"
require "u-case"

# Salesforce is integration with Salesforce API.
module Salesforce; end

require "salesforce/debug"
require "salesforce/timezone"
require "salesforce/credentials"
require "salesforce/error"
require "salesforce/version"
require "salesforce/request"
require "salesforce/oauth"
require "salesforce/oauth_code"
require "salesforce/oauth_code_refresh_token"
require "salesforce/lead"

# Salesforce::V2 is integration with Salesforce.
require "salesforce/v2/request"
