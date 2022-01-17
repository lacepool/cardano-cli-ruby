# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Query
        def initialize(client)
          @client = client
        end

        def tip
          response = @client.run("query tip #{@client.network_argument}")

          return unless response.success?

          JSON.parse(response.data)
        end

        def protocol_params
          @protocol_params ||= @client.run("query protocol-parameters #{@client.network_argument}")
        end

        def utxos(address, ada_only: false)
          case address
          when String
            addr_str = "--address #{address}"
          when Array
            addr_str = address.map { |addr| "--address #{addr}" }.join(" ")
          end

          response = @client.run("query utxo #{addr_str} #{@client.network_argument}")

          utxos = response.data.split(/\n/).drop(2)
          utxos = utxos.map do |utxo|
            split_utxo = utxo.split

            Cardano::Utxo.new(
              txhash: split_utxo[0],
              txix: split_utxo[1].to_i,
              lovelace: split_utxo[2].to_i,
              assets: assets_from_utxo(utxo)
            )
          end

          if ada_only
            utxos.delete_if { |utxo| utxo.assets.any? }
          else
            utxos
          end
        end

        def assets_from_utxo(utxo)
          utxo.gsub!("+ TxOutDatumHashNone", "")
          utxo.gsub!("+ TxOutDatumNone", "")

          utxo.split("+").drop(1).map do |asset|
            split_asset = asset.split

            {}.tap do |h|
              h[:amount] = split_asset[0].to_i
              h[:policy_id] = split_asset[1].split(".")[0]
              h[:asset_name] = split_asset[1].split(".")[1]
            end
          end
        end
      end
    end
  end
end
