# frozen_string_literal: true

require_relative "address"
require_relative "transaction"
require_relative "transactions"
require_relative "../../coin_selection"
require_relative "../../transaction_output"
require_relative "../../utxo"

module Cardano
  module CLI
    module Commands
      class Wallet
        attr_reader :name, :client

        def initialize(client, wallet_name)
          @client = client
          @name = wallet_name
          @payment_addresses = []
        end

        def transactions
          Transactions.new(wallet: self)
        end

        def exist?
          [
            dir,
            payment_skey_file_path,
            payment_vkey_file_path
          ].all? { |f| File.exist?(f) == true }
        end

        def payment_addresses
          Address.all(wallet: self, type: :payment_address)
        end

        def create_payment_address
          Address.create(wallet: self, type: :payment_address)
        end

        def utxos(ada_only: false)
          @client.query.utxos(payment_addresses, ada_only: ada_only)
        end

        def dir
          @dir ||= File.join(Wallets.dir, @name)
        end

        def payment_address_file_paths
          Dir[File.join(dir, "*.addr")]
        end

        def payment_vkey_file_path
          @payment_vkey_file_path ||= File.join(dir, "payment.vkey")
        end

        def payment_skey_file_path
          @payment_skey_file_path ||= File.join(dir, "payment.skey")
        end
      end
    end
  end
end
