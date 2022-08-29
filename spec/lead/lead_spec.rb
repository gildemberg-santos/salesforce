# frozen_string_literal: true

require_relative '../config'

describe Salesforce::Lead do
  before(:all) do
    oauto = Salesforce::OAuth.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET, username: USERNAME, password: PASSWORD, security_token: SECURITY_TOKEN)
    oauto.call
    @lead = Salesforce::Lead.new(access_token: oauto.access_token, instance_url: oauto.instance_url)
    @lead.field!
    # @lead.refresh_token!
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
