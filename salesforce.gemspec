# frozen_string_literal: true

require_relative "lib/salesforce/version"

Gem::Specification.new do |spec|
  spec.name = "salesforce"
  spec.version = Salesforce::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["gildemberg-santos"]
  spec.email = ["gildemberg.santos@gmail.com"]
  spec.summary = "Salesforce Ruby API Gem"
  spec.description = "Salesforce Ruby API client"
  spec.homepage = "http://github.com/gildemberg-santos/salesforce"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.10"

  spec.metadata["allowed_push_host"] = ""
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://github.com/gildemberg-santos/salesforce"
  spec.metadata["changelog_uri"] = "http://github.com/gildemberg-santos/salesforce"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2.1"
  spec.add_dependency "httparty", "~> 0.21.0"
  spec.add_dependency "json", "~> 2.6", ">= 2.6.3"
  spec.add_dependency "u-case", "~> 4.5.2"
  spec.metadata["rubygems_mfa_required"] = "true"
end
