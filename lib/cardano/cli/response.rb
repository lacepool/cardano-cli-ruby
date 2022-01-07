# frozen_string_literal: true

require "forwardable"

module Cardano
  module CLI
    class Response
      extend Forwardable

      attr_reader :data, :error, :status

      def_delegators :@status, :success?

      def initialize(cli_response)
        @data, @error, @status = cli_response
      end
    end
  end
end
