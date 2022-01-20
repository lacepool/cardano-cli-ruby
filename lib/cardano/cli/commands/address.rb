# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Address
        attr_reader :wallet

        def self.all(wallet:, type:)
          case type
          when :payment_address
            wallet.payment_address_file_paths.sort.map do |file|
              new(wallet: wallet, file: file)
            end
          else
            raise "#{type} is not supported"
          end
        end

        def self.create(wallet:, type:)
          case type
          when :payment_address
            number = format("%03d", wallet.payment_address_file_paths.size + 1)
            file_path = File.join(wallet.dir, "#{number}_payment.addr")

            wallet.client.run "address build " \
              "--payment-verification-key-file #{wallet.payment_vkey_file_path} " \
              "--out-file #{file_path} " \
              "#{wallet.client.network_argument}"

            new(wallet: wallet, file: file_path)
          else
            raise "#{type} is not supported"
          end
        end

        def initialize(wallet:, file:)
          raise "File #{file} does not exist" unless File.exist? file

          @file = file
          @wallet = wallet
          @client = @wallet.client
        end

        def address
          @address ||= File.read @file
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
