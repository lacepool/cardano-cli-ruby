# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Wallets
        def self.dir
          @dir ||= File.expand_path(Cardano::CLI.configuration.wallets_path)
        end

        def initialize(client)
          @client = client
          @all = all
        end

        def all
          Dir.glob(File.join(self.class.dir, "/*/")).map do |wallet|
            name = File.basename(entry)
            Wallet.new(@client, name)
          end
        end

        def create(name, without_payment_address: false)
          wallet = Wallet.new(@client, name)

          return self if wallet.exist?

          Dir.mkdir(wallet.dir)

          @client.run "address key-gen " \
            "--verification-key-file #{wallet.payment_vkey_file_path} " \
            "--signing-key-file #{wallet.payment_skey_file_path}"

          if @client.last_response.success?
            wallet.create_payment_address unless without_payment_address
            @all << wallet
          else
            false
          end
        end
      end
    end
  end
end
