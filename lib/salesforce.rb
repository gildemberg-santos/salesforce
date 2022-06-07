# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

# Salesforce is integration with Salesforce API.
module Salesforce; end

require 'salesforce/error'
require 'salesforce/base'
require 'salesforce/version'
require 'salesforce/request'
require 'salesforce/oauth'
require 'salesforce/oauth_code'
require 'salesforce/lead'
