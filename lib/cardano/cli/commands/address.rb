# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Address
        attr_reader :wallet, :file

        def initialize(wallet:, file:)
          raise "File #{file} does not exist" unless File.exist? file

          @file = file
          @wallet = wallet
          @client = @wallet.client
        end

        def address
          @address ||= File.read @file
        end

        def utxos(ada_only: false)
          @client.query.utxos(address, ada_only: ada_only)
        end

        alias_method :to_s, :address

        # def vkey
        #   return unless File.exist? vkey_file_path

        #   @vkey ||= File.read vkey_file_path
        # end

        def info
          @client.run "address info --address #{address}"

          JSON.parse @client.last_response.data
        end

        def key_to_hash
          @client.run "address key-hash " \
            "--payment-verification-key-file #{@wallet.payment_vkey_file_path}"

          @client.last_response.data.strip
        end
      end
    end
  end
end
