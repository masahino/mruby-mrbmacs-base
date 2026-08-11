module Mrbmacs
  TYPESCRIPT_KEYWORDS = 'abstract any as asserts async await bigint boolean break case catch class const constructor continue debugger declare default delete do else enum export extends false finally for from function get global if implements import in infer instanceof interface is keyof let module namespace never new null number object of override package private protected public readonly require return satisfies set static string super switch symbol this throw true try type typeof undefined unique unknown var void while with yield'
  TYPESCRIPT_TYPES = 'Array ArrayBuffer BigInt BigInt64Array BigUint64Array Boolean DataView Date Error Float32Array Float64Array Function Int8Array Int16Array Int32Array Map Number Object Promise Proxy ReadonlyArray Record RegExp Set String Symbol Uint8Array Uint8ClampedArray Uint16Array Uint32Array WeakMap WeakSet'
  TYPESCRIPT_DOCUMENTATION_KEYWORDS = 'abstract access alpha author beta class constructor default deprecated description enum example experimental function ignore implements inheritDoc interface internal link module override package param private property protected public readonly remarks returns see since template this throws typeParam typedef variation version'

  TYPESCRIPT_LEXER_PROFILE = LexerProfile.new(
    :typescript,
    'cpp',
    C_LIKE_LEXER_STYLES.merge(
      Scintilla::SCE_C_WORD2 => :type
    ),
    {
      0 => TYPESCRIPT_KEYWORDS,
      1 => TYPESCRIPT_TYPES,
      2 => TYPESCRIPT_DOCUMENTATION_KEYWORDS,
      5 => C_LIKE_TASK_MARKERS
    },
    {
      'lexer.cpp.enable.preprocessor' => '0',
      'lexer.cpp.allow.dollars' => '1',
      'lexer.cpp.allow.hashes' => '1',
      'lexer.cpp.backquoted.strings' => '2',
      'lexer.cpp.escape.sequence' => '1'
    }
  )
end
