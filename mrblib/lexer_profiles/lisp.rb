module Mrbmacs
  LISP_KEYWORDS = "not defun + - * / = < > <= >= princ \
      eval apply funcall quote identity function complement backquote lambda set setq setf \
      defun defmacro gensym make symbol intern symbol name symbol value symbol plist get \
      getf putprop remprop hash make array aref car cdr caar cadr cdar cddr caaar caadr cadar \
      caddr cdaar cdadr cddar cdddr caaaar caaadr caadar caaddr cadaar cadadr caddar cadddr \
      cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr cons list append reverse last nth \
      nthcdr member assoc subst sublis nsubst  nsublis remove length list length \
      mapc mapcar mapl maplist mapcan mapcon rplaca rplacd nconc delete atom symbolp numberp \
      boundp null listp consp minusp zerop plusp evenp oddp eq eql equal cond case and or let l if prog \
      prog1 prog2 progn go return do dolist dotimes catch throw error cerror break \
      continue errset baktrace evalhook truncate float rem min max abs sin cos tan expt exp sqrt \
      random logand logior logxor lognot bignums logeqv lognand lognor \
      logorc2 logtest logbitp logcount integer length nil"

  LISP_LEXER_PROFILE = LexerProfile.new(
    :lisp,
    'lisp',
    {
      Scintilla::SCE_LISP_DEFAULT => :default,
      Scintilla::SCE_LISP_COMMENT => :comment,
      Scintilla::SCE_LISP_NUMBER => :number,
      Scintilla::SCE_LISP_KEYWORD => :keyword,
      Scintilla::SCE_LISP_KEYWORD_KW => :keyword,
      Scintilla::SCE_LISP_SYMBOL => :function_name,
      Scintilla::SCE_LISP_STRING => :string,
      Scintilla::SCE_LISP_STRINGEOL => :string,
      Scintilla::SCE_LISP_IDENTIFIER => :default,
      Scintilla::SCE_LISP_OPERATOR => :operator,
      Scintilla::SCE_LISP_SPECIAL => :keyword,
      Scintilla::SCE_LISP_MULTI_COMMENT => :comment
    },
    { 0 => LISP_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
