# frozen_string_literal: true

require "irb"
require "vcr"
require "webmock/rspec"
require "salesforce"
require "config"

# Valores que nunca podem ser gravados nos cassettes. Na gravação o VCR troca cada valor pelo
# placeholder; na reprodução faz o caminho inverso usando o que estiver em spec/config.rb.
SENSITIVE_DATA = {
  "<CLIENT_ID>" => CLIENT_ID,
  "<CLIENT_SECRET>" => CLIENT_SECRET,
  "<USERNAME>" => USERNAME,
  "<PASSWORD>" => PASSWORD,
  "<SECURITY_TOKEN>" => SECURITY_TOKEN,
  "<REFRESH_TOKEN>" => REFRESH_TOKEN,
  "<ACCESS_TOKEN>" => ACCESS_TOKEN,
  "<CODE>" => CODE,
  "<INSTANCE_URL>" => INSTANCE_URL
}.freeze

OAUTH_QUERY_PLACEHOLDERS = {
  "client_id" => "<CLIENT_ID>",
  "client_secret" => "<CLIENT_SECRET>",
  "username" => "<USERNAME>",
  "password" => "<PASSWORD><SECURITY_TOKEN>",
  "refresh_token" => "<REFRESH_TOKEN>",
  "code" => "<CODE>"
}.freeze

INSTANCE_HOST_REGEX = %r{https://(?!login\.salesforce\.com)[a-z0-9-]+(?:\.[a-z0-9-]+)*\.(?:salesforce|force)\.com}

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = { decode_compressed_response: true }

  SENSITIVE_DATA.each do |placeholder, value|
    config.filter_sensitive_data(placeholder) { value } unless value.to_s.empty?
  end

  # Segredos que a API devolve (tokens, URL da instância) não são conhecidos de antemão,
  # então são removidos por padrão antes de cada gravação.
  config.before_record do |interaction|
    request = interaction.request
    response = interaction.response

    OAUTH_QUERY_PLACEHOLDERS.each do |param, placeholder|
      request.uri = request.uri.gsub(/([?&]#{param}=)[^&]*/) { "#{Regexp.last_match(1)}#{placeholder}" }
    end
    request.uri = request.uri.gsub(INSTANCE_HOST_REGEX, "<INSTANCE_URL>")

    authorization = request.headers["Authorization"]
    authorization&.map! { |value| value.sub(/\ABearer \S+/, "Bearer <ACCESS_TOKEN>") }

    body = response.body.to_s.dup
    body.gsub!(/"(access_token|refresh_token)":"[^"]+"/) { %("#{Regexp.last_match(1)}":"<#{Regexp.last_match(1).upcase}>") }
    body.gsub!(/"signature":"[^"]+"/, '"signature":"<SIGNATURE>"')
    body.gsub!(%r{"id":"https://login\.salesforce\.com/id/[^"]+"},
               '"id":"https://login.salesforce.com/id/00D000000000000AAA/005000000000000AAA"')
    body.gsub!(/"instance_url":"[^"]+"/, '"instance_url":"<INSTANCE_URL>"')
    body.gsub!(INSTANCE_HOST_REGEX, "https://example.my.salesforce.com")
    response.body = body

    response.headers["Set-Cookie"]&.map! { |cookie| cookie.sub(/BrowserId=[^;]+/, "BrowserId=<BROWSER_ID>") }
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
