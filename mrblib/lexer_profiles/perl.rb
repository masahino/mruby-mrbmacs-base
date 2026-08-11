module Mrbmacs
  PERL_KEYWORDS = "NULL __FILE__ __LINE__ __PACKAGE__ __DATA__ __END__ AUTOLOAD \
      BEGIN CORE DESTROY END EQ GE GT INIT LE LT NE CHECK abs accept \
      alarm and atan2 bind binmode bless caller chdir chmod chomp chop \
      chown chr chroot close closedir cmp connect continue cos crypt \
      dbmclose dbmopen defined delete die do dump each else elsif endgrent \
      endhostent endnetent endprotoent endpwent endservent eof eq eval \
      exec exists exit exp fcntl fileno flock for foreach fork format \
      formline ge getc getgrent getgrgid getgrnam gethostbyaddr gethostbyname \
      gethostent getlogin getnetbyaddr getnetbyname getnetent getpeername \
      getpgrp getppid getpriority getprotobyname getprotobynumber getprotoent \
      getpwent getpwnam getpwuid getservbyname getservbyport getservent \
      getsockname getsockopt glob gmtime goto grep gt hex if index \
      int ioctl join keys kill last lc lcfirst le length link listen \
      local localtime lock log lstat lt map mkdir msgctl msgget msgrcv \
      msgsnd my ne next no not oct open opendir or ord our pack package \
      pipe pop pos print printf prototype push quotemeta qu \
      rand read readdir readline readlink readpipe recv redo \
      ref rename require reset return reverse rewinddir rindex rmdir \
      scalar seek seekdir select semctl semget semop send setgrent \
      sethostent setnetent setpgrp setpriority setprotoent setpwent \
      setservent setsockopt shift shmctl shmget shmread shmwrite shutdown \
      sin sleep socket socketpair sort splice split sprintf sqrt srand \
      stat study sub substr symlink syscall sysopen sysread sysseek \
      system syswrite tell telldir tie tied time times truncate \
      uc ucfirst umask undef unless unlink unpack unshift untie until \
      use utime values vec wait waitpid wantarray warn while write \
      xor \
      given when default say state UNITCHECK"

  PERL_LEXER_PROFILE = LexerProfile.new(
    :perl,
    'perl',
    {
      Scintilla::SCE_PL_DEFAULT => :default,
      Scintilla::SCE_PL_ERROR => :error,
      Scintilla::SCE_PL_COMMENTLINE => :comment,
      Scintilla::SCE_PL_POD => :documentation,
      Scintilla::SCE_PL_NUMBER => :number,
      Scintilla::SCE_PL_WORD => :keyword,
      Scintilla::SCE_PL_STRING => :string,
      Scintilla::SCE_PL_CHARACTER => :string,
      Scintilla::SCE_PL_PUNCTUATION => :default,
      Scintilla::SCE_PL_PREPROCESSOR => :preprocessor,
      Scintilla::SCE_PL_OPERATOR => :operator,
      Scintilla::SCE_PL_IDENTIFIER => :default,
      Scintilla::SCE_PL_SCALAR => :variable_name,
      Scintilla::SCE_PL_ARRAY => :variable_name,
      Scintilla::SCE_PL_HASH => :variable_name,
      Scintilla::SCE_PL_SYMBOLTABLE => :variable_name,
      Scintilla::SCE_PL_VARIABLE_INDEXER => :variable_name,
      Scintilla::SCE_PL_REGEX => :regexp,
      Scintilla::SCE_PL_REGSUBST => :regexp,
      Scintilla::SCE_PL_LONGQUOTE => :string,
      Scintilla::SCE_PL_BACKTICKS => :string,
      Scintilla::SCE_PL_DATASECTION => :preprocessor,
      Scintilla::SCE_PL_HERE_DELIM => :string,
      Scintilla::SCE_PL_HERE_Q => :string,
      Scintilla::SCE_PL_HERE_QQ => :string,
      Scintilla::SCE_PL_HERE_QX => :string,
      Scintilla::SCE_PL_STRING_Q => :string,
      Scintilla::SCE_PL_STRING_QQ => :string,
      Scintilla::SCE_PL_STRING_QX => :string,
      Scintilla::SCE_PL_STRING_QR => :regexp,
      Scintilla::SCE_PL_STRING_QW => :string,
      Scintilla::SCE_PL_POD_VERB => :documentation,
      Scintilla::SCE_PL_SUB_PROTOTYPE => :preprocessor,
      Scintilla::SCE_PL_FORMAT_IDENT => :preprocessor,
      Scintilla::SCE_PL_FORMAT => :preprocessor,
      Scintilla::SCE_PL_STRING_VAR => :variable_name,
      Scintilla::SCE_PL_XLAT => :regexp,
      Scintilla::SCE_PL_REGEX_VAR => :variable_name,
      Scintilla::SCE_PL_REGSUBST_VAR => :variable_name,
      Scintilla::SCE_PL_BACKTICKS_VAR => :variable_name,
      Scintilla::SCE_PL_HERE_QQ_VAR => :variable_name,
      Scintilla::SCE_PL_HERE_QX_VAR => :variable_name,
      Scintilla::SCE_PL_STRING_QQ_VAR => :variable_name,
      Scintilla::SCE_PL_STRING_QX_VAR => :variable_name,
      Scintilla::SCE_PL_STRING_QR_VAR => :variable_name
    },
    { 0 => PERL_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
