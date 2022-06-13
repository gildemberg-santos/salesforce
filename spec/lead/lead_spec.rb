# frozen_string_literal: true

require_relative '../config'

describe Salesforce::Lead do
  before(:all) do
    oauth = Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN)
    oauth.call
    @lead = Salesforce::Lead.new(oauth.access_token, oauth.instance_url)
  end

  it { expect(@lead.fields).not_to eq nil }

  it { expect(@lead.required_fields).to eq %w[Company LastName] }

  it {
    expect do
      @lead.send({})
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Required fields are missing: [LastName, Company]')))
  }

  it {
    expect do
      @lead.send({ 'Company' => 'Test' })
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Required fields are missing: [LastName]')))
  }

  it {
    expect do
      @lead.send({ 'LastName' => 'Test' })
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Required fields are missing: [Company]')))
  }

  it { expect(@lead.send({ 'Company' => 'Test', 'LastName' => 'Test' })['success']).to eq true }
end
