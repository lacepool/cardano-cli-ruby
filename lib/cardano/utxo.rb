# frozen_string_literal: true

module Cardano
  class Utxo
    attr_reader :txix, :txhash, :lovelace, :assets

    def initialize(lovelace:, txhash:, txix:, assets: [])
      @lovelace = lovelace
      @txhash = txhash
      @txix = txix
      @assets = assets
    end
  end
end
