# Ruby syntax style preview for mrbmacs.
#
# This file is for visual inspection, not execution. Open it in Ruby mode and
# compare the constructs below when changing a theme or lexer profile.

require 'json'

module StylePreview
  DEFAULT_LIMIT = 1_000
  SYMBOL = :ready

  class Renderer
    @@instances = 0

    attr_reader :name

    def initialize(name = 'mrbmacs')
      @name = name
      @@instances += 1
    end

    def render(enabled: true)
      local_value = 0x2a + 3.14
      status = enabled ? :active : :inactive

      plain = "double quoted: #{name}"
      literal = 'single quoted'
      percent_q = %q(literal percent string)
      percent_qq = %Q(interpolated percent string: #{status})
      words = %w[alpha beta gamma]
      symbols = %i[red green blue]
      regexp = /ruby\s+style/i
      percent_regexp = %r{mrbmacs/.+\.rb}i
      command = `printf style-preview`

      document = <<~TEXT
        heredoc with interpolation: #{local_value}
      TEXT

      literal_document = <<~'TEXT'
        literal heredoc: #{not_interpolated}
      TEXT

      $stdout.puts [plain, literal, percent_q, percent_qq]
      $stderr.puts words.join(', ')
      $stdin if regexp.match?(document) && percent_regexp

      { status: status, symbols: symbols, command: command,
        document: literal_document }
    rescue StandardError => error
      warn "render failed: #{error.message}"
    end
  end
end

# The invalid instance-variable token is intentional: it exercises the Ruby
# lexer's error style. Keep it near the end so it does not obscure other styles.
invalid_token = @1

=begin
Ruby POD documentation block.
It should use the documentation semantic role.
=end

__END__
Ruby data section. It should also use the documentation semantic role.
