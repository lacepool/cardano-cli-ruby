# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Transactions
        def initialize(wallet:)
          @wallet = wallet
        end

        def create(outputs = [], to: nil, lovelace: nil, ttl: 3600)
          Transaction.new(outputs, wallet: @wallet, to: to, lovelace: lovelace, ttl: ttl).tap do |tx|
            tx.draft
            tx.calculate_fees
            tx.calculate_change
            tx.build
            tx.sign
            tx.submit
          end
        end
      end
    end
  end
end
