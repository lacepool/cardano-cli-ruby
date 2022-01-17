# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Transaction
        attr_reader :fees, :outputs, :change_address

        def initialize(outputs = [], wallet:, to: nil, lovelace: nil, ttl: nil)
          @wallet = wallet
          @client = @wallet.client

          @outputs = outputs.map do |output|
            Cardano::TransactionOutput.new(address: output[:to], lovelace: output[:lovelace])
          end

          if to && lovelace
            @outputs << Cardano::TransactionOutput.new(address: to, lovelace: lovelace)
          end

          @change_address = @wallet.payment_addresses.sample
          @fees = 0
          @ttl = ttl
          @transaction_file_name = Time.now.to_i
        end

        def draft
          @draft_file_path = File.join(@wallet.transactions_path, "#{@transaction_file_name}.draft")

          @client.run "transaction build-raw " \
            "#{serialized_inputs.join(' ')} " \
            "#{serialized_outputs.join(' ')} " \
            "--tx-out #{@change_address}+0 " \
            "--invalid-hereafter 0 " \
            "--fee 0 " \
            "--out-file #{@draft_file_path}"

          return false unless @client.last_response.success?

          @draft_file_path
        end

        def calculate_fees
          @client.run "transaction calculate-min-fee " \
            "--tx-body-file #{@draft_file_path} " \
            "--tx-in-count #{@utxos.size} " \
            "--tx-out-count #{@outputs.size + 1} " \
            "--witness-count 1 " \
            "--byron-witness-count 0 " \
            "#{@client.network_argument} " \
            "--protocol-params-file #{@client.query.protocol_params}"

          return false unless @client.last_response.success?

          @fees = @client.last_response.data
        end

        def change
          @change = @outputs.sum(&:change) - @fees
        end

        def build
          @unsigned_file_path = File.join(@wallet.transactions_path, "#{@transaction_file_name}.raw")

          @client.run "transaction build-raw " \
            "#{serialized_inputs.join(' ')} " \
            "#{serialized_ouputs.join(' ')} " \
            "--tx-out #{@change_address}+#{change}" \
            "--invalid-hereafter #{valid_until_slot} " \
            "--fee #{@fees} " \
            "--out-file #{@_file}"

          return false unless @client.last_response.success?

          @unsigned_file_path
        end

        def sign
          @signed_file_path = File.join(@wallet.transactions_path, "#{@transaction_file_name}.signed")

          @client.run "transaction sign " \
            "--tx-body-file #{@unsigned_file_path} " \
            "--signing-key-file #{@wallet.payment_skey_file_path} " \
            "#{@client.network_argument} " \
            "--out-file #{@signed_file_path}"

          return false unless @client.last_response.success?

          @signed_file_path
        end

        def submit
          @client.run "transaction submit " \
            "--tx-file #{@signed_file_path} " \
            "#{@client.network_argument}"

          return false unless @client.last_response.success?

          self
        end

        def utxos
          @utxos ||= @wallet.utxos(ada_only: true)
        end

        def serialized_inputs
          @serialized_inputs ||= coin_selection.selected_utxos.map do |utxo|
            "--tx-in #{utxo.txhash}##{utxo.txix}"
          end
        end

        def serialized_outputs
          @serialized_outputs ||= @outputs.map do |output|
            "--tx-out #{output.address}+#{output.lovelace}"
          end
        end

        def valid_until_slot
          @wallet.query.tip.fetch("slotNo") + @ttl
        end

        def coin_selection
          @coin_selection ||= Cardano::CoinSelection.new(outputs: @outputs, utxos: utxos)
        end
      end
    end
  end
end
