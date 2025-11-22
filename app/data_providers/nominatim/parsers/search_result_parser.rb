module Nominatim
  module Parsers
    class SearchResultParser
      attr_reader :raw_result

      def initialize(raw_result)
        @raw_result = raw_result
      end

      def call
        # @todo implement
      end
    end
  end
end
