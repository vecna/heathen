module Heathen
  module Encoders
    class Base

      MIME_TYPES = %{}

      attr_reader :app

      class << self
        def valid_mime_type?(mime_type)
          return self::MIME_TYPES.include?(mime_type)
        end
      end

      def initialize(app)
        @app = app
      end

      protected


    end
  end
end
