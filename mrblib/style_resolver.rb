module Mrbmacs
  # User style overrides, ordered from semantic to exact Scintilla style.
  class StyleOverrides
    def initialize
      @global = {}
      @lexer = {}
      @scintilla = {}
    end

    def override(role, attributes = {})
      attributes = attributes.dup
      lexer = attributes.delete(:lexer)
      style = StyleSpec.new(attributes)
      if lexer
        @lexer[lexer] ||= {}
        @lexer[lexer][StyleRole.normalize(role)] = style
      else
        @global[StyleRole.normalize(role)] = style
      end
      style
    end

    def override_scintilla(lexer, style_number, attributes = {})
      @scintilla[lexer] ||= {}
      @scintilla[lexer][style_number] = StyleSpec.new(attributes)
    end

    def global(role)
      @global[StyleRole.normalize(role)]
    end

    def lexer(lexer, role)
      styles = @lexer[lexer]
      styles && styles[StyleRole.normalize(role)]
    end

    def scintilla(lexer, style_number)
      styles = @scintilla[lexer]
      styles && styles[style_number]
    end
  end

  # Resolves semantic roles through a theme and applies them to Scintilla.
  class StyleResolver
    def initialize(theme, overrides = nil)
      @theme = theme
      @overrides = overrides
    end

    def resolve(role, options = {})
      lexer = options[:lexer]
      style_number = options[:style_number]
      normalized = StyleRole.normalize(role)
      style = @theme.syntax_style(normalized)
      return nil unless style

      if @overrides
        style = style.merge(@overrides.global(normalized))
        style = style.merge(@overrides.lexer(lexer, normalized)) if lexer
        style = style.merge(@overrides.scintilla(lexer, style_number)) if lexer && !style_number.nil?
      end
      style
    end

    def apply(view, profile)
      profile.styles.each do |style_number, role|
        style = resolve(role, lexer: profile.name, style_number: style_number)
        next unless style

        view.sci_style_set_fore(style_number, style.foreground) unless style.foreground.nil?
        view.sci_style_set_back(style_number, style.background) unless style.background.nil?
        view.sci_style_set_italic(style_number, style.italic) unless style.italic.nil?
        view.sci_style_set_bold(style_number, style.bold) unless style.bold.nil?
      end
    end
  end
end
