# frozen_string_literal: true

require "spec_helper"

RSpec.describe Salesforce::OAuthCode do
  it "Pass the client_id null" do
    expect do
      Salesforce::OAuthCode.new(client_id: nil, client_secret: CLIENT_SECRET, redirect_uri: REDIRECT_URI)
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Client ID is required")))
  end

  it "Pass the client_secret null" do
    expect do
      Salesforce::OAuthCode.new(client_id: CLIENT_ID, client_secret: nil, redirect_uri: REDIRECT_URI)
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Client secret is required")))
  end

  it "Pass the redirect_uri null" do
    expect do
      Salesforce::OAuthCode.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET, redirect_uri: nil)
    end.to raise_error(an_instance_of(Salesforce::Error).and(having_attributes(message: "Redirect URI is required")))
  end

  it "Pass the code not null" do
    oauth_code = Salesforce::OAuthCode.new(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI
    )
    oauth_code.code = CODE
    expect(oauth_code.code).to_not be_nil
  end

  it "Authorize endpoint" do
    oauth_code = Salesforce::OAuthCode.new(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI
    )
    expect(oauth_code.authorize).to_not be_nil
  end

  # it 'Access token and Instance url' do
  #   oauth_code = Salesforce::OAuthCode.new(
  #  client_id: CLIENT_ID, client_secret: CLIENT_SECRET, redirect_uri: REDIRECT_URI)
  #   puts oauth_code.authorize
  #   oauth_code.code = CODE
  #   oauth_code.call
  #   puts oauth_code.access_token
  #   puts oauth_code.refresh_token
  #   puts oauth_code.instance_url

  #   expect(oauth_code.access_token).to_not be_nil
  #   expect(oauth_code.refresh_token).to_not be_nil
  #   expect(oauth_code.instance_url).to_not be_nil
  # end
end
