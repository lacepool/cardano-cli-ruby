# frozen_string_literal: true

require_relative "address"

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
