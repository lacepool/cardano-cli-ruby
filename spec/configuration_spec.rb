# frozen_string_literal: true

require 'spec_helper'

describe Cardano::CLI do
  subject { described_class.new }

  describe "configuration" do
    it "has default settings" do
      expect(subject.configuration.network).to eq :testnet
      expect(subject.configuration.cli_path).to eq nil
      expect(subject.configuration.wallets_path).to eq nil
      expect(subject.configuration.logger).to be_a(Logger)
    end

    it "allows to change settings" do
      described_class.configure do |c|
        c.network = :mainnet
        c.cli_path = "/bin/cardano-cli"
        c.wallets_path = "/cardano/wallets"
      end

      expect(subject.configuration.network).to eq :mainnet
      expect(subject.configuration.cli_path).to eq "/bin/cardano-cli"
      expect(subject.configuration.wallets_path).to eq "/cardano/wallets"
    end
  end
end
