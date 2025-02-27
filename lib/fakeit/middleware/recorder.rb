module Fakeit
  module Middleware
    class Recorder
      def initialize(app)
        @app = app
      end

      def call(env)
        env
          .tap(&method(:log_request))
          .then { |e| @app.call(e) }
          .tap(&method(:log_response))
      end

      private

      def log_request(env)
        env['rack.input']
          &.tap { |body| Logger.info("Request body: #{body.read}") }
          &.tap { |body| body.rewind }
      end

      def log_response(response)
        Logger.info("Response body: #{response[2].first}")
      end
    end
  end
end
