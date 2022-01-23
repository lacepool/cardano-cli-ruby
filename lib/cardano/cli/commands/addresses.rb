# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Addresses
        def initialize(wallet:)
          @wallet = wallet
        end

        def all(type:)
          case type
          when :payment
            @wallet.payment_address_file_paths.sort.map do |file|
              Address.new(wallet: @wallet, file: file)
            end
          else
            raise "#{type} is not supported"
          end
        end

        def create(type:)
          case type
          when :payment
            number = format("%03d", @wallet.payment_address_file_paths.size + 1)
            file_path = File.join(@wallet.dir, "#{number}_payment.addr")

            @wallet.client.run "address build " \
              "--payment-verification-key-file #{@wallet.payment_vkey_file_path} " \
              "--out-file #{file_path} " \
              "#{@wallet.client.network_argument}"

            Address.new(wallet: @wallet, file: file_path)
          else
            raise "#{type} is not supported"
          end
        end
      end
    end
  end
end
