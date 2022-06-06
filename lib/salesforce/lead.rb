# frozen_string_literal: true

require 'salesforce/error'
require 'salesforce/requests'
require 'salesforce/version'

module Salesforce
  class Lead
    def initialize(access_token, instance_url, api_version = API_VERSION)
      @access_token = access_token
      @instance_url = instance_url
      @api_version = api_version
    end

    def endpoint_field
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead/describe"
    end

    def endpoint_list
      "#{@instance_url}/services/data/#{@api_version}/query?q=SELECT+Id+FROM+Lead"
    end

    def endpoint_info(lead_id)
      "#{@instance_url}/services/data/#{@api_version}/sobjects/Lead/#{lead_id}"
    end

    def endpoint_send; end
  end
end
