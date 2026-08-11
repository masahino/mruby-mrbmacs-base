module Mrbmacs
  GO_KEYWORDS = 'break default func interface select case defer go map struct chan else goto package switch const fallthrough if range type continue for import return var bool int int8 int16 int32 int64 byte uint uint8 uint16 uint32 uint64 uintptr float float32 float64 string nil true false'

  GO_LEXER_PROFILE = LexerProfile.new(
    :go,
    'cpp',
    C_LIKE_LEXER_STYLES,
    {
      0 => GO_KEYWORDS,
      5 => C_LIKE_TASK_MARKERS
    },
    {
      'lexer.cpp.backquoted.strings' => '1',
      'lexer.cpp.escape.sequence' => '1'
    }
  )
end
