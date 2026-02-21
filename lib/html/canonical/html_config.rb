module Html
  module Canonical
    class HtmlConfig
      attr_reader :theme, :auto_id_prefix

      def initialize(theme:, auto_id_prefix:)
        raise TypeError, "`theme` must be 'light' | 'dark'" unless [ "light", "dark" ].include?(theme)
        @theme = theme
        @auto_id_prefix = auto_id_prefix
      end
    end
  end
end
