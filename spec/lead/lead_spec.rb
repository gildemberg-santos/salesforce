# frozen_string_literal: true

require_relative '../config'

describe Salesforce::Lead do
  before(:all) do
    Salesforce.client_id = CLIENT_ID
    Salesforce.client_secret = CLIENT_SECRET
    @lead = Salesforce::Lead.new(access_token: ACCESS_TOKEN, refresh_token: REFRESH_TOKEN, instance_url: INSTANCE_URL)
    @lead.field!
    @lead.refresh_token!
  end

  it { expect(@lead.fields).not_to eq nil }

  it { expect(@lead.required_fields.length).to be > 0 }

  it {
    expect do
      @lead.send({})
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Payload is required')))
  }

  it {
    expect do
      @lead.send({ 'Company' => 'Test' })
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Required fields are missing: [LastName, marcas__c]')))
  }

  it {
    expect do
      @lead.send({ 'LastName' => 'Test' })
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: 'Required fields are missing: [Company, marcas__c]')))
  }

  it { expect(@lead.send({ 'Company' => 'Test', 'LastName' => 'Test', 'marcas__c' => 'carro' })['success']).to eq true }

end
