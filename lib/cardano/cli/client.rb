# frozen_string_literal: true

require_relative "commands/query"

module Cardano
  module CLI
    class Client
      attr_reader :configuration

      def initialize(config)
        @configuration = config

        @cli_path = @configuration.cli_path
        @network = @configuration.network
        @network_argument = network_argument
      end

      def run(cmd)
        stdout, stderr, status = Open3.capture3("#{@cli_path} #{cmd}")

        if status.success?
          stdout
        else
          { error: stderr, status: status }.to_json
        end
      end

      def query
        Cardano::CLI::Commands::Query.new(self)
      end

      def network_argument
        return @network_argument if @network_argument

        case @network.to_sym
        when :testnet
          @network_argument = "--testnet-magic 1097911063"
        when :mainnet
          @network_argument = "--mainnet"
        else
          raise ConfigurationError,
                "network is configured to be #{@network.inspect} " \
                "but can only be testnet or mainnet"
        end
      end

      class ConfigurationError < StandardError; end
    end
  end
end
