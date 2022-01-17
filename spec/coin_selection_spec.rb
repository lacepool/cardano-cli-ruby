# frozen_string_literal: true

require 'spec_helper'

describe Cardano::CoinSelection do
  it "defaults to the random_improve algorithm" do
    expect(
      described_class.new.algorithm
    ).to eq :random_improve
  end

  describe "#random_improve_tolerance" do
    it "defaults to 0.25" do
      expect(described_class.new.random_improve_tolerance).to eq(0.25)
    end
  end

  context "when chosen algorithm doesn't exist" do
    it "raises error" do
      expect {
        described_class.new(algorithm: :foobar).run
      }.to raise_error(Cardano::CoinSelection::AlgorithmNotImplementedError)
    end
  end

  context "when not enough funds available" do
    let(:output) do
      Cardano::TransactionOutput.new(address: "addr1abc", lovelace: 20_000_000)
    end

    let(:utxo) do
      Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 10_000_000)
    end

    it "raises balance insufficient error" do
      expect {
        described_class.new(outputs: [output], utxos: [utxo])
      }.to raise_error(Cardano::CoinSelection::UtxoBalanceInsufficientError)
    end
  end

  context "when more outputs requested than utxos available" do
    let(:outputs) do
      [
        Cardano::TransactionOutput.new(address: "addr1abc", lovelace: 5_000_000),
        Cardano::TransactionOutput.new(address: "addr1def", lovelace: 10_000_000),
      ]
    end

    let(:utxos) do
      [
        Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 50_000_000)
      ]
    end

    it "raises fragmantation error" do
      expect {
        described_class.new(outputs: outputs, utxos: utxos)
      }.to raise_error(Cardano::CoinSelection::UtxoNotFragmentedEnoughError)
    end
  end

  context "when enough funds available (twice the requested amount minus the tolerance)" do
    context "when only one single output requested" do
      let(:output) do
        Cardano::TransactionOutput.new(address: "addr1abc", lovelace: 20_000_000)
      end

      context "with only one single utxo available" do
        let(:utxo) do
          Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 100_000_000)
        end

        describe "#run" do
          it "assigns the utxo to the output" do
            expect(output.utxos).to be_empty
            described_class.new(outputs: [output], utxos: [utxo]).run
            expect(output.utxos).to match_array(utxo)
          end
        end
      end

      context "with multiple utxos sufficient enough when combined" do
        let(:utxos) do
          [
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 10_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 15_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 12_000_000),
          ]
        end

        describe "#run" do
          it "assigns all utxos to the output" do
            expect(output.utxos).to be_empty
            described_class.new(outputs: [output], utxos: utxos).run
            expect(output.utxos).to match_array(utxos)
          end
        end
      end
    end

    context "with multiple outputs" do
      let(:outputs) do
        [
          Cardano::TransactionOutput.new(address: "addr1abc", lovelace: 5_000_000),
          Cardano::TransactionOutput.new(address: "addr1def", lovelace: 10_000_000),
        ]
      end

      context "when one output consumes so many utxo another output can not be fulfilled anymore" do
        let(:utxos) do
          [
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 2_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 3_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 10_000_000),
          ]
        end

        describe "#run" do
          it "raises utxos fully depleted error" do
            expect {
              described_class.new(outputs: outputs, utxos: utxos).run
            }.to raise_error(Cardano::CoinSelection::UtxoFullyDepletedError)
          end
        end
      end

      context "when the available utxos can fulfill all outputs" do
        let(:utxos) do
          [
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 5_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 10_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 15_000_000),
            Cardano::Utxo.new(txhash: "..", txix: 1, lovelace: 50_000_000),
          ]
        end

        describe "#run" do
          it "assigns sufficient utxos to all outputs" do
            described_class.new(outputs: outputs, utxos: utxos).run

            outputs.each do |output|
              expect(output.utxos.sum(&:lovelace)).to be >= output.lovelace
            end
          end
        end
      end
    end
  end
end
