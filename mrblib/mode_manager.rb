module Mrbmacs
  # Mrbmacs::Mode
  class ModeManager
    @@mode_list = {
      # ruby-mode
      '.rb' => 'ruby',
      '.rake' => 'ruby',
      'Rakefile' => 'ruby',
      '.mrbmacsrc' => 'ruby',
      '.c' => 'cpp',
      '.h' => 'cpp',
      '.cpp' => 'cpp',
      '.cxx' => 'cpp',
      '.m' => 'objectivec',
      '.mm' => 'objectivec',
      '.css' => 'css',
      '.diff' => 'diff',
      '.java' => 'java',
      '.js' => 'javascript',
      '.ts' => 'typescript',
      '.json' => 'json',
      '.md' => 'markdown',
      '.txt' => 'fundamental',
      '.hs' => 'haskell',
      '.html' => 'html',
      '.htm' => 'html',
      '.lisp' => 'lisp',
      '.lua' => 'lua',
      '.erb' => 'html',
      '.sh' => 'bash',
      '.go' => 'go',
      '.pl' => 'perl',
      '.pov' => 'pov',
      '.py' => 'python',
      '.r' => 'r',
      '.rs' => 'rust',
      '.tex' => 'latex',
      '.xml' => 'xml',
      '.plist' => 'xml',
      '.yml' => 'yaml',
      '.yaml' => 'yaml',
      'Makefile' => 'make',
      'makefile' => 'make',
      '' => 'fundamental',
      '*scratch*' => 'irb',
      '*compilation*' => 'compilation',
      '*Messages*' => 'fundamental',
      '*preview_theme*' => 'previewtheme',
      '*grep*' => 'grep',
      '*Project Search*' => 'projectsearch'
    }

    def self.add_mode(suffix_or_filename, mode_name)
      @@mode_list[suffix_or_filename] = mode_name
    end

    def self.get_mode_by_suffix(suffix)
      if @@mode_list.key?(suffix)
        @@mode_list[suffix]
      else
        'fundamental'
      end
    end

    def self.get_mode_by_filename(filename)
      key = File.extname(filename)
      key = File.basename(filename) if key == ''
      if @@mode_list.key?(key)
        @@mode_list[key]
      else
        'fundamental'
      end
    end

    def self.get_mode_by_name(mode_name)
      if Mrbmacs.const_defined?("#{mode_name.capitalize}Mode")
        Mrbmacs.const_get("#{mode_name.capitalize}Mode").instance
      else
        nil
      end
    end

    def self.set_mode_by_filename(filename)
      cur_mode = get_mode_by_filename(filename)
      Mrbmacs.const_get("#{cur_mode.capitalize}Mode").instance
    end
  end
end
