# frozen_string_literal: true

require_relative "address"
require_relative "addresses"
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
        end

        def transactions
          Transactions.new(wallet: self)
        end

        def addresses
          Addresses.new(wallet: self)
        end

        def exist?
          [
            base_path,
            payment_skey_file_path,
            payment_vkey_file_path
          ].all? { |f| File.exist?(f) == true }
        end

        def payment_addresses
          addresses.all(type: :payment)
        end

        def create_payment_address
          addresses.create(type: :payment)
        end

        def utxos(ada_only: false)
          @client.query.utxos(payment_addresses, ada_only: ada_only)
        end

        def base_path
          @base_path ||= File.join(@client.wallets_path, @name)
        end

        def payment_address_file_paths
          Dir[File.join(base_path, "*.addr")]
        end

        def payment_vkey_file_path
          @payment_vkey_file_path ||= File.join(base_path, "payment.vkey")
        end

        def payment_skey_file_path
          @payment_skey_file_path ||= File.join(base_path, "payment.skey")
        end
      end
    end
  end
end
