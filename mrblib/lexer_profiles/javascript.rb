module Mrbmacs
  JAVASCRIPT_KEYWORDS = 'async await break case catch class const continue debugger default delete do else export extends false finally for from function get if import in instanceof let new null of return set static super switch this throw true try typeof var void while with yield'
  JAVASCRIPT_BUILTINS = 'console document globalThis Infinity JSON Math NaN Reflect undefined window'
  JAVASCRIPT_DOCUMENTATION_KEYWORDS = 'abstract access alias async augments author borrows callback class constant constructor copyright default deprecated description enum event example exports external file fires function generator global hideconstructor ignore implements inheritDoc inner instance interface kind lends license listens member mixes mixin module name namespace override package param private property protected public readonly requires returns see since static summary this throws todo tutorial type typedef variation version yields'
  JAVASCRIPT_CLASSES = 'Array ArrayBuffer BigInt BigInt64Array BigUint64Array Boolean DataView Date Error EvalError FinalizationRegistry Float32Array Float64Array Function Int8Array Int16Array Int32Array Map Number Object Promise Proxy RangeError ReferenceError RegExp Set SharedArrayBuffer String Symbol SyntaxError TypeError Uint8Array Uint8ClampedArray Uint16Array Uint32Array URIError WeakMap WeakRef WeakSet'

  JAVASCRIPT_LEXER_PROFILE = LexerProfile.new(
    :javascript,
    'cpp',
    C_LIKE_LEXER_STYLES.merge(
      Scintilla::SCE_C_WORD2 => :builtin
    ),
    {
      0 => JAVASCRIPT_KEYWORDS,
      1 => JAVASCRIPT_BUILTINS,
      2 => JAVASCRIPT_DOCUMENTATION_KEYWORDS,
      3 => JAVASCRIPT_CLASSES,
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
