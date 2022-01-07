# frozen_string_literal: true

module Cardano
  module CLI
    module Commands
      class Query
        def initialize(client)
          @client = client
        end

        def tip
          @client.run("query tip #{@client.network_argument}")
        end

        def utxo(addr)
          response = @client.run("query utxo --address #{addr} #{@client.network_argument}")

          utxos = response.data.split(/\n/).drop(2)
          utxos.map do |utxo|
            split_utxo = utxo.split

            {}.tap do |h|
              h[:txhash] = split_utxo[0]
              h[:txix] = split_utxo[1].to_i
              h[:lovelace] = split_utxo[2].to_i
              h[:assets] = assets_from_utxo(utxo)
            end
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
