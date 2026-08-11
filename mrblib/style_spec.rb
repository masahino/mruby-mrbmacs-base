module Mrbmacs
  # Named style attributes with support for partial inheritance.
  class StyleSpec
    attr_accessor :foreground, :background, :italic, :bold

    def initialize(options = {})
      @foreground = options[:foreground]
      @background = options[:background]
      @italic = options[:italic]
      @bold = options[:bold]
    end

    def self.from_legacy(value)
      return value if value.is_a?(StyleSpec)
      return nil unless value.is_a?(Array)

      new(foreground: value[0], background: value[1], italic: value[2], bold: value[3])
    end

    def merge(override)
      return dup unless override

      StyleSpec.new(
        foreground: override.foreground.nil? ? @foreground : override.foreground,
        background: override.background.nil? ? @background : override.background,
        italic: override.italic.nil? ? @italic : override.italic,
        bold: override.bold.nil? ? @bold : override.bold
      )
    end

    def dup
      StyleSpec.new(
        foreground: @foreground,
        background: @background,
        italic: @italic,
        bold: @bold
      )
    end
  end
end
