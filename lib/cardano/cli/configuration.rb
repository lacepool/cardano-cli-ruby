# frozen_string_literal: true

require "logger"

module Cardano
  module CLI
    class << self
      def configuration
        @configuration ||= OpenStruct.new(configuration_defaults)
      end

      def configuration_defaults
        {
          network: :testnet,
          cli_path: nil,
          wallets_path: nil,
          logger: Logger.new($stdout),
        }
      end

      def configure
        yield(configuration)
      end

      def new(config = configuration)
        Client.new(config)
      end
    end
  end
end
