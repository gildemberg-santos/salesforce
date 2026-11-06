# Salesforce Ruby Gem

[![Build Status](https://github.com/gildemberg-santos/salesforce/actions/workflows/main.yml/badge.svg)](https://github.com/gildemberg-santos/salesforce/actions)

[Português](README.pt-BR.md)

A Ruby gem that makes it easy to integrate with the Salesforce API.

It provides a simple, efficient interface for authentication, queries and data manipulation through Salesforce.

---

## 📦 Installation

### Add it to your Gemfile

```ruby
gem 'salesforce'
```

Then run:

```bash
bundle install
```

### Or install it manually

```bash
gem install salesforce
```

### System dependency

> **Important:** on Debian/Ubuntu-based systems you need `ruby-dev`:

```bash
sudo apt install ruby-dev
```

---

## 🚀 Usage

### Interactive console

Start an interactive prompt with the gem loaded:

```bash
bin/console
```

### Example

```ruby
require 'salesforce'

client = Salesforce::Client.new(
  client_id: ENV['SALESFORCE_CLIENT_ID'],
  client_secret: ENV['SALESFORCE_CLIENT_SECRET'],
  username: ENV['SALESFORCE_USERNAME'],
  password: ENV['SALESFORCE_PASSWORD']
)

# Query example
result = client.query("SELECT Id, Name FROM Account LIMIT 10")
puts result
```

> More usage examples coming soon.

---

## 🛠 Development

### Clone and set up

After cloning the repository, run:

```bash
bin/setup
```

To open an interactive console with the environment loaded:

```bash
bin/console
```

### Running the tests

The suite uses [VCR](https://github.com/vcr/vcr) and runs without any credentials:

```bash
bundle exec rspec
```

The cassettes in `spec/vcr_cassettes/` contain only placeholders (`<CLIENT_ID>`, `<ACCESS_TOKEN>`, `<INSTANCE_URL>`...), and `spec/spec_helper.rb` strips tokens and org URLs before anything is recorded.

To re-record a cassette against a real org, copy `spec/config.exemplo.yaml` to `spec/config.yaml` (ignored by Git) or set the `SALESFORCE_<KEY>` variables (e.g. `SALESFORCE_CLIENT_ID`), delete the cassette and run the suite. Review the diff before committing.

### Installing locally

```bash
bundle exec rake install
```

### Releasing a new version

1. Update the version in `lib/salesforce/version.rb`
2. Run:

```bash
bundle exec rake release
```

This command:
- Creates a Git tag for the new version
- Pushes the commits and the tag to GitHub
- Publishes the new version to [RubyGems.org](https://rubygems.org)

---

## 🤝 Contributing

Bug reports and pull requests are welcome on the [GitHub repository](https://github.com/gildemberg-santos/salesforce).

This project is meant to be a safe, welcoming space for collaboration. See the [Code of Conduct](https://github.com/gildemberg-santos/salesforce/blob/master/CODE_OF_CONDUCT.md).

---

## 📄 License

Released under the [MIT License](https://opensource.org/licenses/MIT).
