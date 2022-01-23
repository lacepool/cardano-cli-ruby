# frozen_string_literal: true

require 'spec_helper'

describe Cardano::CLI do
  subject { described_class.new }

  describe "configuration" do
    before do
      allow(Dir).to receive(:mkdir) # don't create base folder
    end

    it "instantiates a new client object" do
      expect(subject).to be_a(Cardano::CLI::Client)
    end

    it "has default settings" do
      expect(subject.configuration.network).to eq :testnet
      expect(subject.configuration.cli_path).to eq nil
      expect(subject.configuration.root_path).to eq "./"
      expect(subject.configuration.logger).to be_a(Logger)
    end

    it "allows to change settings" do
      described_class.configure do |c|
        c.network = :mainnet
        c.cli_path = "/bin/cardano-cli"
        c.root_path = "./spec"
      end

      expect(subject.configuration.network).to eq :mainnet
      expect(subject.configuration.cli_path).to eq "/bin/cardano-cli"
      expect(subject.configuration.root_path).to eq "./spec"
    end
  end
end
