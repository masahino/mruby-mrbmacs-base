class MatchData
  alias_method :__mruby4_initialize, :initialize
  alias_method :__mruby4_begin, :begin
  alias_method :__mruby4_end, :end

  def initialize(*args)
    __mruby4_initialize(nil)
  end

  def begin(index)
    offset_base = @offset_base || 0
    pos = __mruby4_begin(index)
    pos.nil? ? nil : pos + offset_base
  end

  def end(index)
    offset_base = @offset_base || 0
    pos = __mruby4_end(index)
    pos.nil? ? nil : pos + offset_base
  end
end

class Regexp
  alias_method :__mruby4_match, :match

  def match(str, pos = 0)
    match = __mruby4_match(str[pos..-1] || '')
    return nil if match.nil?

    match.instance_variable_set(:@offset_base, pos)
    match.instance_variable_set(:@string, str)
    match
  end
end
