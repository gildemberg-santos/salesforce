require_relative '../config'

describe Salesforce::OAuth do
  it 'Pass the client_id null' do
    expect { Salesforce::OAuth.new(nil, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Client ID is required'))
  end
  it 'Pass the client_secret null' do
    expect { Salesforce::OAuth.new(CLIENT_ID, nil, USERNAME, PASSWORD, SECURITY_TOKEN, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Client secret is required'))
  end
  it 'Pass the username null' do
    expect { Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, nil, PASSWORD, SECURITY_TOKEN, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Username is required'))
  end
  it 'Pass the password null' do
    expect { Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, nil, SECURITY_TOKEN, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Password is required'))
  end
  it 'Pass the security_token null' do
    expect { Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, nil, API_VERSION) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'Security token is required'))
  end
  it 'Pass the api_version null' do
    expect { Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN, nil) }.to raise_error(an_instance_of(Salesforce::Error).and having_attributes(message: 'API version is required'))
  end
  it 'Call method call' do
    expect(Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN).call).to be_nil
  end
  it 'Access token and Instance url' do
    oauth = Salesforce::OAuth.new(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD, SECURITY_TOKEN)
    oauth.call
    expect(oauth.access_token).to_not be_nil
    expect(oauth.instance_url).to_not be_nil
  end
end