require_relative '../config'

describe Salesforce::Lead do
  before(:all) do
    oauth = Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN)
    oauth.call
    @lead = Salesforce::Lead.new(oauth.access_token, oauth.instance_url)
  end

  it { expect(@lead.fields).not_to eq nil }

  it { expect(@lead.requered_fields).to eq ["Company", "LastName"] }

  it { expect(@lead.send({})[0]["message"]).to eq "Required fields are missing: [LastName, Company]"}

  it { expect(@lead.send({"Company" => "Test"})[0]["message"]).to eq "Required fields are missing: [LastName]" }

  it { expect(@lead.send({"LastName" => "Test"})[0]["message"]).to eq "Required fields are missing: [Company]" }

  it { expect(@lead.send({"Company" => "Test", "LastName" => "Test"})["success"]).to eq true }
end