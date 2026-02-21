module Html
  module Canonical
    class HtmlNode
      attr_accessor :tag_name, :attrs, :children, :categories, :is_text

      def initialize(tag_name:, attrs:, children:, categories:, is_text:)
        @tag_name = tag_name
        @attrs = attrs || {}
        @children = children || []
        @categories = categories
        @is_text = is_text
      end

      def has?(category:)
        self.categories.include?(category)
      end

      def ==(other)
        other.is_a?(HtmlNode) &&
        self.tag_name   == other.tag_name &&
        self.attrs      == other.attrs &&
        self.children   == other.children &&
        self.categories == other.categories &&
        self.is_text    == other.is_text
      end

      def eql?(other)
        self == other
      end
    end
  end
end
