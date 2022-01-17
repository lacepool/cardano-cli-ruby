# frozen_string_literal: true

# This class implements the coin selection algorithms
# Current supported algorithm: Random Improve
#
# Read the detailed specifiction: https://cips.cardano.org/cips/cip2/#randomimprove

module Cardano
  class CoinSelection
    attr_reader :algorithm, :outputs, :initial_utxos, :remaining_utxos
    attr_accessor :random_improve_tolerance

    def initialize(outputs: [], utxos: [], algorithm: :random_improve)
      @algorithm = algorithm
      @outputs = outputs
      @initial_utxos = utxos.dup
      @remaining_utxos = @initial_utxos
      @random_improve_tolerance = 0.25

      verify_utxos!
    end

    def run
      case @algorithm
      when :random_improve
        random_select
        expand_selection
      else
        raise AlgorithmNotImplementedError
      end
    end

    def random_select
      @outputs.sort_by(&:lovelace).reverse!.each do |output|
        until output.utxos.sum(&:lovelace) >= output.lovelace
          assign_random_utxo_to_output(output)
        end
      end
    end

    def expand_selection
      @outputs.sort_by(&:lovelace).each do |output|
        desired_utxo_amount = output.lovelace * 2
        tolerance = desired_utxo_amount * random_improve_tolerance
        min_utxo_amount = desired_utxo_amount - tolerance

        until output.utxos.sum(&:lovelace) >= min_utxo_amount
          assign_random_utxo_to_output(output)
        end
      end
    end

    def assign_random_utxo_to_output(output)
      raise UtxoFullyDepletedError if @remaining_utxos.empty?

      output.utxos << @remaining_utxos.delete(@remaining_utxos.sample)
      output.calculate_change
    end

    def verify_utxos!
      if @initial_utxos.sum(&:lovelace) < @outputs.sum(&:lovelace)
        raise UtxoBalanceInsufficientError,
              "Total value of available UTxO #{@initial_utxos.sum(&:lovelace)} " \
              "is not sufficient enough to cover the " \
              "requested payment of #{@outputs.sum(&:lovelace)}"
      end

      if @remaining_utxos.size < @outputs.size
        raise UtxoNotFragmentedEnoughError,
              "Not enough UTxO available to build transaction. " \
              "Only #{@remaining_utxos.size} UTxO for #{@outputs.size} Outputs."
      end
    end

    def selected_utxos
      @initial_utxos - @remaining_utxos
    end

    class AlgorithmNotImplementedError < StandardError; end
    class UtxoBalanceInsufficientError < StandardError; end
    class UtxoNotFragmentedEnoughError < StandardError; end
    class UtxoFullyDepletedError < StandardError; end
  end
end
