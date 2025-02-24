# frozen_string_literal: true

require "spec_helper"

RSpec.describe Salesforce::V2::Lead::Create do
  subject { described_class.call(payload: payload) }

  let(:payload) do
    {
      "Name" => "Gildemberg Santos Gomes",
      "Rating" => "",
      "Status" => "Open - Not Contacted",
      "Company" => "Leadster",
      "Industry" => "",
      "batata__c" => "",
      "marcas__c" => "",
      "LeadSource" => "",
      "Primary__c" => "",
      "Salutation" => "",
      "CleanStatus" => "",
      "IsConverted" => "False",
      "GeocodeAccuracy" => "",
      "IsUnreadByOwner" => "False",
      "TesteBoleano__c" => "False",
      "ProductInterest__c" => ""
    }
  end

  describe ".call" do
    let(:data) { subject.data }

    context "when failure" do
      context "when invalid payload" do
        let(:payload) { nil }

        it { is_expected.to be_failure }
        it { expect(data[:invalid_payload]).to be_truthy }
      end
    end
    context "when successful" do
      it { is_expected.to be_success }
      it { expect(data[:message]).to eq("Lead created successfully!") }
      it { expect(data.dig(:payload, :Name)).not_to eq("Gildemberg Santos Gomes") }
      it { expect(data.dig(:payload, :FirstName)).to eq("Gildemberg") }
      it { expect(data.dig(:payload, :LastName)).to eq("Santos Gomes") }
      it { expect(data.dig(:payload, :Rating)).to eq(nil) }
      it { expect(data.dig(:payload, :Status)).to eq("Open - Not Contacted") }
      it { expect(data.dig(:payload, :Company)).to eq("Leadster") }
      it { expect(data.dig(:payload, :Industry)).to eq(nil) }
      it { expect(data.dig(:payload, :batata__c)).to eq(nil) }
      it { expect(data.dig(:payload, :marcas__c)).to eq(nil) }
      it { expect(data.dig(:payload, :LeadSource)).to eq(nil) }
      it { expect(data.dig(:payload, :Primary__c)).to eq(nil) }
      it { expect(data.dig(:payload, :Salutation)).to eq(nil) }
      it { expect(data.dig(:payload, :CleanStatus)).to eq(nil) }
      it { expect(data.dig(:payload, :IsConverted)).to eq("False") }
      it { expect(data.dig(:payload, :GeocodeAccuracy)).to eq(nil) }
      it { expect(data.dig(:payload, :IsUnreadByOwner)).to eq("False") }
      it { expect(data.dig(:payload, :TesteBoleano__c)).to eq("False") }
      it { expect(data.dig(:payload, :ProductInterest__c)).to eq(nil) }
    end
  end
end
