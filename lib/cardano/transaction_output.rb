# frozen_string_literal: true

module Cardano
  class TransactionOutput
    attr_reader :address, :lovelace, :change
    attr_accessor :utxos

    def initialize(address:, lovelace:, utxos: [])
      @address = address
      @lovelace = lovelace
      @utxos = utxos
      @change = 0
    end

    def fulfilled?
      @utxos.sum(&:lovelace) >= lovelace
    end

    def calculate_change
      @change = @utxos.sum(&:lovelace) - lovelace
    end
  end
end
