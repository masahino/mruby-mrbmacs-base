module Mrbmacs
  OBJECTIVEC_KEYWORDS = '@autoreleasepool @catch @class @compatibility_alias @defs @dynamic @encode @end @finally @implementation @interface @optional @package @private @property @protected @protocol @public @required @selector @synchronized @synthesize @throw @try BOOL Class IMP NO Nil Protocol SEL YES id nil self super'
  OBJECTIVEC_TYPES = 'NSInteger NSUInteger CGFloat CGPoint CGRect CGSize NSRange NSString NSArray NSDictionary NSNumber NSObject'
  OBJECTIVEC_DOCUMENTATION_KEYWORDS = 'brief class code def enum example exception file fn param return see struct throws todo typedef var warning'

  OBJECTIVEC_LEXER_PROFILE = LexerProfile.new(
    :objectivec,
    'cpp',
    C_LIKE_LEXER_STYLES.merge(
      Scintilla::SCE_C_WORD2 => :type
    ),
    {
      0 => "#{CPP_KEYWORDS} #{OBJECTIVEC_KEYWORDS}",
      1 => OBJECTIVEC_TYPES,
      2 => OBJECTIVEC_DOCUMENTATION_KEYWORDS,
      5 => C_LIKE_TASK_MARKERS
    },
    {
      'lexer.cpp.track.preprocessor' => '0',
      'lexer.cpp.escape.sequence' => '1'
    }
  )
end
