require 'bootstrapper/transport'
require 'bootstrapper/transport_session'

module Bootstrapper
  module Transports

    class TestTransportSession < TransportSession

      def scp(io_or_string, remote_path)
      end

      def pty_run(command)
      end

      def run(command)
      end

      def sudo(command)
      end

    end

    class TestTransport < Transport

      short_name :test_transport

      option :transport_opt,
             :type => :string,
             :desc => "Sets an option for test transport"

      def connect
        @session = TestTransportSession.new(ui, :transport_session, options)
        yield @session
      end

    end
  end
end
