require_relative '../config'

describe Salesforce::OAuthCode do
  it 'Pass the client_id null' do
    expect { Salesforce::OAuthCode.new(nil, CLIENT_SECRET, REDIRECT_URI, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Client ID is required'))
  end

  it 'Pass the client_secret null' do
    expect { Salesforce::OAuthCode.new(CLIENT_ID, nil, REDIRECT_URI, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Client secret is required'))
  end

  it 'Pass the redirect_uri null' do
    expect { Salesforce::OAuthCode.new(CLIENT_ID, CLIENT_SECRET, nil, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Redirect URI is required'))
  end

  it 'Pass the api_version null' do
    expect { Salesforce::OAuthCode.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, nil) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'API version is required'))
  end

  it 'Call method call' do
    oauth_code = Salesforce::OAuthCode.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, API_VERSION)
    oauth_code.code = CODE
    expect(oauth_code.call).to be_nil
  end

  it 'Authorize endpoint' do
    oauth_code = Salesforce::OAuthCode.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, API_VERSION)
    expect(oauth_code.authorize).to_not be_nil
  end

  # it 'Access token and Instance url' do
  #   oauth_code = Salesforce::OAuthCode.new(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, API_VERSION)
  #   oauth_code.code = CODE
  #   oauth_code.call
  #   expect(oauth_code.access_token).to_not be_nil
  #   expect(oauth_code.instance_url).to_not be_nil
  # end
end