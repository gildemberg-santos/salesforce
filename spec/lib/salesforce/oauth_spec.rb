# frozen_string_literal: true

require "spec_helper"

RSpec.describe Salesforce::OAuth do
  it "Pass the client_id null" do
    expect do
      Salesforce::OAuth.new(
        client_id: nil,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: PASSWORD,
        security_token: SECURITY_TOKEN
      )
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Client ID is required")))
  end
  it "Pass the client_secret null" do
    expect do
      Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: nil,
        username: USERNAME,
        password: PASSWORD,
        security_token: SECURITY_TOKEN
      )
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Client secret is required")))
  end
  it "Pass the username null" do
    expect do
      Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: nil,
        password: PASSWORD,
        security_token: SECURITY_TOKEN
      )
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Username is required")))
  end
  it "Pass the password null" do
    expect do
      Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: nil,
        security_token: SECURITY_TOKEN
      )
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Password is required")))
  end
  it "Pass the security_token null" do
    expect do
      Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: PASSWORD,
        security_token: nil
      )
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Security token is required")))
  end
  it "Call method call" do
    VCR.use_cassette("salesforce_oauth") do
      expect(Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: PASSWORD,
        security_token: SECURITY_TOKEN
      ).call).to be_nil
    end
  end
  it "Access token and Instance url" do
    VCR.use_cassette("salesforce_oauth") do
      oauth = Salesforce::OAuth.new(
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        username: USERNAME,
        password: PASSWORD,
        security_token: SECURITY_TOKEN
      )
      oauth.call

      expect(oauth.access_token).to_not be_nil
      expect(oauth.instance_url).to_not be_nil
    end
  end
end
