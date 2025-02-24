# frozen_string_literal: true

require "spec_helper"

RSpec.describe Salesforce::Lead do
  context "Lead" do
    before(:all) do
      VCR.use_cassette("salesforce_lead") do
        oauto = Salesforce::OAuth.new(
          client_id: CLIENT_ID,
          client_secret: CLIENT_SECRET,
          username: USERNAME,
          password: PASSWORD,
          security_token: SECURITY_TOKEN
        )
        oauto.call

        @lead = Salesforce::Lead.new(access_token: oauto.access_token, instance_url: oauto.instance_url)
        @lead.field!
      end
    end

    it { expect(@lead.fields).not_to eq nil }

    it { expect(@lead.required_fields.length).to be_positive }

    it {
      expect do
        @lead.send({})
      end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Payload is required")))
    }

    it {
      VCR.use_cassette("salesforce_lead_error_company") do
        expect do
          @lead.send({ "Company" => "Test" })
        end.to raise_error(
          an_instance_of(Salesforce::Error).and(
            having_attributes(message: "Required fields are missing: [LastName]")
          )
        )
      end
    }

    it {
      VCR.use_cassette("salesforce_lead_error_last_name") do
        expect do
          @lead.send({ "LastName" => "Test" })
        end.to raise_error(
          an_instance_of(Salesforce::Error).and(
            having_attributes(message: "Required fields are missing: [Company]")
          )
        )
      end
    }

    it {
      VCR.use_cassette("salesforce_lead_error_company_last_name") do
        expect(
          @lead.send({ "Company" => "Test", "LastName" => "Test" })["success"]
        ).to eq true
      end
    }

    it { expect(@lead.required_fields).to eq(%w[Name Company Status]) }
  end
end
