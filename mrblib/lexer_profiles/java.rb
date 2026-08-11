module Mrbmacs
  JAVA_KEYWORDS = 'abstract assert boolean break byte case catch char class const continue default do double else enum extends false final finally float for goto if implements import instanceof int interface long native new null package permits private protected public record return sealed short static strictfp super switch synchronized this throw throws transient true try var void volatile when while yield'
  JAVA_TYPES = 'String Object Class Enum Record Number Boolean Byte Character Short Integer Long Float Double Void'
  JAVA_DOCUMENTATION_KEYWORDS = 'author code deprecated docRoot exception hidden index inheritDoc link linkplain literal param provides return see serial serialData serialField since snippet summary systemProperty throws uses value version'
  JAVA_CLASSES = 'ArrayList Collection Collections HashMap HashSet Iterable List Map Optional Set Stream System Throwable'

  JAVA_LEXER_PROFILE = LexerProfile.new(
    :java,
    'cpp',
    C_LIKE_LEXER_STYLES.merge(
      Scintilla::SCE_C_WORD2 => :type
    ),
    {
      0 => JAVA_KEYWORDS,
      1 => JAVA_TYPES,
      2 => JAVA_DOCUMENTATION_KEYWORDS,
      3 => JAVA_CLASSES,
      5 => C_LIKE_TASK_MARKERS
    },
    {
      'lexer.cpp.enable.preprocessor' => '0',
      'lexer.cpp.escape.sequence' => '1',
      'lexer.cpp.triplequoted.strings' => '1'
    }
  )
end
