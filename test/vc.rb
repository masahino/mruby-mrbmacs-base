def vc_runner(results)
  proc do |_directory, arguments|
    results[arguments] || ['', 1]
  end
end

def recording_vc_runner(results, calls)
  proc do |directory, arguments|
    calls << [directory, arguments]
    results[arguments] || ['', 1]
  end
end

def vc_command_app(diff, diff_status = 0)
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'lib/file.rb'] => [diff, diff_status]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)
  app
end

assert('VC quotes git arguments for the POSIX shell') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner(['rev-parse', '--show-toplevel'] => ['', 128]))

  assert_equal "'plain'", vcinfo.send(:shell_quote, 'plain')
  assert_equal "'file name.rb'", vcinfo.send(:shell_quote, 'file name.rb')
  assert_equal %q('file name'"'"'s $HOME;touch marker'),
               vcinfo.send(:shell_quote, "file name's $HOME;touch marker")
  assert_equal "''", vcinfo.send(:shell_quote, '')
end

assert('VC run_git returns output and exit status from IO.popen') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner(['rev-parse', '--show-toplevel'] => ['', 128]))

  output, status = vcinfo.send(:run_git, '.', ['--version'])

  assert_equal 0, status
  assert_true output.start_with?('git version ')
end

assert('VC run_git captures git errors and a nonzero exit status') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner(['rev-parse', '--show-toplevel'] => ['', 128]))

  output, status = vcinfo.send(:run_git, '.', ['diff', '--definitely-invalid-option'])

  assert_true status != 0
  assert_true output != ''
end

assert('VC managed repository') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('.', runner)

  assert_true vcinfo.managed?
  assert_equal :git, vcinfo.type
  assert_equal '/work/project', vcinfo.root_directory
  assert_equal 'main', vcinfo.branch
  assert_equal 'Git:main', vcinfo.to_s
end

assert('VC detached HEAD') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ['', 1],
    ['rev-parse', '--short', 'HEAD'] => ["1a2b3c4\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('.', runner)

  assert_true vcinfo.detached?
  assert_equal '@1a2b3c4', vcinfo.branch
  assert_equal 'Git:@1a2b3c4', vcinfo.to_s
end

assert('VC unmanaged directory') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner(['rev-parse', '--show-toplevel'] => ['', 128]))

  assert_false vcinfo.managed?
  assert_equal :unmanaged, vcinfo.state
  assert_equal '', vcinfo.to_s
end

assert('VC git unavailable') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner(['rev-parse', '--show-toplevel'] => ['', 127]))

  assert_false vcinfo.managed?
  assert_equal :unavailable, vcinfo.state
  assert_equal '', vcinfo.to_s
end

assert('VC diff uses a repository-relative path') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', 'HEAD', '--', 'lib/file name.rb'] => ["diff output\n", 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_equal ["diff output\n", 0], vcinfo.diff('/work/project/lib/file name.rb')
  assert_equal '/work/project', calls.last[0]
end

assert('VC diff rejects a path outside the repository') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('/work/project', runner)
  output, status = vcinfo.diff('/work/another/file.rb')

  assert_equal 1, status
  assert_include output, 'outside the repository'
end

assert('VC stage uses a repository-relative path') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['add', '--', 'lib/file name.rb'] => ['', 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_equal ['', 0], vcinfo.stage('/work/project/lib/file name.rb')
  assert_equal ['/work/project', ['add', '--', 'lib/file name.rb']], calls.last
end

assert('VC stage rejects a path outside the repository') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('/work/project', runner)
  output, status = vcinfo.stage('/work/another/file.rb')

  assert_equal 1, status
  assert_include output, 'outside the repository'
end

assert('VC unstage restores only the index for a repository-relative path') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['restore', '--staged', '--', 'lib/file name.rb'] => ['', 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_equal ['', 0], vcinfo.unstage('/work/project/lib/file name.rb')
  assert_equal ['/work/project', ['restore', '--staged', '--', 'lib/file name.rb']], calls.last
end

assert('VC unstage rejects a path outside the repository') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project', runner)
  previous_calls = calls.length
  output, status = vcinfo.unstage('/work/another/file.rb')

  assert_equal 1, status
  assert_include output, 'outside the repository'
  assert_equal previous_calls, calls.length
end

assert('VC status runs in the repository root') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['status', '--porcelain=v1', '-z'] => [" M lib/file.rb\0", 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_equal [[{
    index: ' ', worktree: 'M', path: 'lib/file.rb', original_path: nil
  }], 0], vcinfo.status
  assert_equal ['/work/project', ['status', '--porcelain=v1', '-z']], calls.last
end

assert('VC status parses staged, untracked, and renamed paths') do
  output = "M  staged.rb\0?? new file.rb\0R  renamed.rb\0old.rb\0"
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['status', '--porcelain=v1', '-z'] => [output, 0]
  )
  vcinfo = Mrbmacs::VC.new('/work/project', runner)

  entries, status = vcinfo.status

  assert_equal 0, status
  assert_equal [
    { index: 'M', worktree: ' ', path: 'staged.rb', original_path: nil },
    { index: '?', worktree: '?', path: 'new file.rb', original_path: nil },
    { index: 'R', worktree: ' ', path: 'renamed.rb', original_path: 'old.rb' }
  ], entries
end

assert('VC parses zero-context diff hunks') do
  diff = <<~DIFF
    diff --git a/file.rb b/file.rb
    @@ -2,0 +3,2 @@
    +added
    +lines
    @@ -10,2 +12,3 @@ method
    @@ -20,4 +22,0 @@
  DIFF

  assert_equal [
    { type: :added, old_start: 2, old_count: 0, new_start: 3, new_count: 2 },
    { type: :modified, old_start: 10, old_count: 2, new_start: 12, new_count: 3 },
    { type: :deleted, old_start: 20, old_count: 4, new_start: 22, new_count: 0 }
  ], Mrbmacs::VC.parse_diff_hunks(diff)
end

assert('VC parses omitted hunk counts as one line') do
  diff = "@@ -7 +7 @@\n"

  assert_equal [
    { type: :modified, old_start: 7, old_count: 1, new_start: 7, new_count: 1 }
  ], Mrbmacs::VC.parse_diff_hunks(diff)
end

assert('VC maps additions and modifications to new file lines') do
  changes = [
    { type: :added, new_start: 3, new_count: 2 },
    { type: :modified, new_start: 8, new_count: 1 }
  ]

  assert_equal [
    [:added, 2],
    [:added, 3],
    [:modified, 7]
  ], Mrbmacs::VC.marker_lines(changes)
end

assert('VC maps a deletion to the preceding line') do
  changes = [
    { type: :deleted, new_start: 4, new_count: 0 },
    { type: :deleted, new_start: 0, new_count: 0 }
  ]

  assert_equal [
    [:deleted, 3],
    [:deleted, 0]
  ], Mrbmacs::VC.marker_lines(changes)
end

assert('VC changes returns parsed zero-context hunks') do
  calls = []
  diff = "@@ -2,0 +3,2 @@\n+first\n+second\n"
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'lib/file.rb'] => [diff, 0]
  }, calls)
  vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  changes, status = vcinfo.changes('/work/project/lib/file.rb')

  assert_equal 0, status
  assert_equal [
    { type: :added, old_start: 2, old_count: 0, new_start: 3, new_count: 2 }
  ], changes
  assert_equal '/work/project', calls.last[0]
end

assert('VC changes returns an error status when git diff fails') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'file.rb'] => ['', 128]
  )
  vcinfo = Mrbmacs::VC.new('/work/project', runner)

  assert_equal [[], 128], vcinfo.changes('/work/project/file.rb')
end

assert('VC changes rejects a path outside the repository') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('/work/project', runner)

  assert_equal [[], 1], vcinfo.changes('/work/another/file.rb')
end

assert('vc_diff displays the current file diff') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', 'HEAD', '--', 'lib/file.rb'] => ["diff output\n", 0]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  app.vc_diff

  assert_equal '*vc-diff*', app.current_buffer.name
  assert_equal 'diff', app.current_buffer.mode.name
end

assert('vc_diff reports no differences') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', 'HEAD', '--', 'lib/file.rb'] => ['', 0]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  app.vc_diff

  assert_equal 'No differences', app.frame.echo_message
end

assert('vc_diff rejects a buffer not visiting a file') do
  app = Mrbmacs::TestSupport::Application.new

  app.vc_diff

  assert_equal 'Buffer is not visiting a file', app.frame.echo_message
end

assert('vc_refresh_gutter replaces VC markers') do
  diff = <<~DIFF
    @@ -2,0 +3,2 @@
    +first
    +second
    @@ -8 +10 @@
    @@ -14,2 +15,0 @@
  DIFF
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'lib/file.rb'] => [diff, 0]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)
  messages = app.frame.view_win.messages
  before_delete = messages.count { |message| message == Scintilla::SCI_MARKERDELETEALL }
  before_add = messages.count { |message| message == Scintilla::SCI_MARKERADD }

  app.send(:vc_refresh_gutter)

  assert_equal 3, messages.count { |message| message == Scintilla::SCI_MARKERDELETEALL } - before_delete
  assert_equal 4, messages.count { |message| message == Scintilla::SCI_MARKERADD } - before_add
end

assert('vc_next_change moves to the next hunk and wraps') do
  diff = <<~DIFF
    @@ -3 +3 @@
    @@ -8 +8 @@
    @@ -15,2 +15,0 @@
  DIFF
  app = vc_command_app(diff)
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_GETCURRENTPOS] = 20
  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 4

  app.vc_next_change

  assert_equal [7], win.last_args(Scintilla::SCI_GOTOLINE)

  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 14
  app.vc_next_change

  assert_equal [2], win.last_args(Scintilla::SCI_GOTOLINE)
end

assert('vc_previous_change moves to the previous hunk and wraps') do
  diff = <<~DIFF
    @@ -3 +3 @@
    @@ -8 +8 @@
    @@ -15,2 +15,0 @@
  DIFF
  app = vc_command_app(diff)
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_GETCURRENTPOS] = 20
  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 7

  app.vc_previous_change

  assert_equal [2], win.last_args(Scintilla::SCI_GOTOLINE)

  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 2
  app.vc_previous_change

  assert_equal [14], win.last_args(Scintilla::SCI_GOTOLINE)
end

assert('vc_next_change reports when the file has no changes') do
  app = vc_command_app('')

  app.vc_next_change

  assert_equal 'No VC changes', app.frame.echo_message
end

assert('vc_next_change reports a git diff failure') do
  app = vc_command_app('', 128)

  app.vc_next_change

  assert_equal 'Git diff failed', app.frame.echo_message
end

assert('vc_next_change rejects a file not managed by Git') do
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/file.rb'
  app.current_buffer.directory = '/work'
  app.current_buffer.vcinfo = Mrbmacs::VC.new(
    '/work',
    vc_runner(['rev-parse', '--show-toplevel'] => ['', 128])
  )

  app.vc_next_change

  assert_equal 'File is not in a Git repository', app.frame.echo_message
end

assert('vc_stage_file stages the current file and refreshes the gutter') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['add', '--', 'lib/file.rb'] => ['', 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'lib/file.rb'] => ['', 0]
  }, calls)
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)
  messages = app.frame.view_win.messages
  before_delete = messages.count { |message| message == Scintilla::SCI_MARKERDELETEALL }

  assert_true app.vc_stage_file
  assert_include calls, ['/work/project', ['add', '--', 'lib/file.rb']]
  assert_equal 3, messages.count { |message| message == Scintilla::SCI_MARKERDELETEALL } - before_delete
  assert_equal 'File staged', app.frame.echo_message
end

assert('vc_stage_file rejects a buffer with unsaved changes') do
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.frame.view_win.test_return[Scintilla::SCI_GETMODIFY] = 1

  assert_false app.vc_stage_file
  assert_equal 'Buffer has unsaved changes', app.frame.echo_message
end

assert('vc_stage_file reports a git add failure') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['add', '--', 'lib/file.rb'] => ["git add failed\n", 128]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_false app.vc_stage_file
  assert_equal 'git add failed', app.frame.echo_message
end

assert('vc_unstage_file accepts unsaved changes and refreshes the gutter') do
  calls = []
  runner = recording_vc_runner({
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['restore', '--staged', '--', 'lib/file.rb'] => ['', 0],
    ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', 'lib/file.rb'] => ['', 0]
  }, calls)
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)
  view = app.frame.view_win
  view.test_return[Scintilla::SCI_GETMODIFY] = 1
  before_delete = view.count_of(Scintilla::SCI_MARKERDELETEALL)

  assert_true app.vc_unstage_file
  assert_include calls, ['/work/project', ['restore', '--staged', '--', 'lib/file.rb']]
  assert_equal 3, view.count_of(Scintilla::SCI_MARKERDELETEALL) - before_delete
  assert_equal 'File unstaged', app.frame.echo_message
end

assert('vc_unstage_file rejects a buffer not visiting a file') do
  app = Mrbmacs::TestSupport::Application.new

  assert_false app.vc_unstage_file
  assert_equal 'Buffer is not visiting a file', app.frame.echo_message
end

assert('vc_unstage_file rejects a file not managed by Git') do
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/file.rb'
  app.current_buffer.directory = '/work'
  app.current_buffer.vcinfo = Mrbmacs::VC.new(
    '/work', vc_runner(['rev-parse', '--show-toplevel'] => ['', 128])
  )

  assert_false app.vc_unstage_file
  assert_equal 'File is not in a Git repository', app.frame.echo_message
end

assert('vc_unstage_file reports a git restore failure without refreshing the gutter') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['restore', '--staged', '--', 'lib/file.rb'] => ["pathspec did not match\n", 1]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.filename = '/work/project/lib/file.rb'
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)
  view = app.frame.view_win
  before_delete = view.count_of(Scintilla::SCI_MARKERDELETEALL)

  assert_false app.vc_unstage_file
  assert_equal before_delete, view.count_of(Scintilla::SCI_MARKERDELETEALL)
  assert_equal 'pathspec did not match', app.frame.echo_message
end

assert('vc_status displays the working tree status in a read-only buffer') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['status', '--porcelain=v1', '-z'] => [" M lib/file.rb\0?? test/new.rb\0", 0]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.directory = '/work/project/lib'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project/lib', runner)

  assert_true app.vc_status
  assert_equal '*VC Status*', app.current_buffer.name
  output = app.frame.view_win.last_args(Scintilla::SCI_SETTEXT)[1]
  assert_true output.start_with?("+-- Index: M modified/staged")
  assert_true output.include?("|+-- Worktree: M modified, D deleted\n")
  assert_true output.include?("||  ?? untracked\n")
  assert_true output.include?(" M lib/file.rb\n")
  assert_true output.include?("?? test/new.rb\n")
  assert_equal 'vc-status', app.current_buffer.mode.name
  assert_equal [nil, nil, nil, 'lib/file.rb', 'test/new.rb'], app.current_buffer.mode.paths
  assert_equal [1], app.frame.view_win.last_args(Scintilla::SCI_SETREADONLY)
end

assert('vc_status reports a clean working tree') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['status', '--porcelain=v1', '-z'] => ['', 0]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.directory = '/work/project'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project', runner)

  assert_true app.vc_status
  output = app.frame.view_win.last_args(Scintilla::SCI_SETTEXT)[1]
  assert_true output.include?("Working tree clean\n")
end

assert('vc_status reports a git status failure') do
  runner = vc_runner(
    ['rev-parse', '--show-toplevel'] => ["/work/project\n", 0],
    ['symbolic-ref', '--quiet', '--short', 'HEAD'] => ["main\n", 0],
    ['status', '--porcelain=v1', '-z'] => ["git status failed\n", 128]
  )
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.directory = '/work/project'
  app.current_buffer.vcinfo = Mrbmacs::VC.new('/work/project', runner)

  assert_false app.vc_status
  assert_equal 'Git status failed', app.frame.echo_message
end

assert('VCStatusMode opens the file for the current status line') do
  app = Mrbmacs::TestSupport::Application.new
  mode = Mrbmacs::VCStatusMode.new
  mode.root_directory = '/work/project'
  mode.paths = [nil, nil, nil, 'lib/example.rb']
  app.current_buffer.mode = mode
  app.frame.view_win.test_return[Scintilla::SCI_GETCURRENTPOS] = 20
  app.frame.view_win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 3
  app.frame.edit_win_list << app.frame.edit_win
  app.define_singleton_method(:other_window) { nil }
  opened_file = nil
  app.define_singleton_method(:find_file) { |file| opened_file = file }

  app.vc_status_open_file

  assert_equal '/work/project/lib/example.rb', opened_file
end

assert('VCStatusMode ignores a header line') do
  app = Mrbmacs::TestSupport::Application.new
  mode = Mrbmacs::VCStatusMode.new
  mode.root_directory = '/work/project'
  mode.paths = [nil, nil, nil, 'lib/example.rb']
  app.current_buffer.mode = mode
  app.frame.view_win.test_return[Scintilla::SCI_GETCURRENTPOS] = 0
  app.frame.view_win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 0
  opened_file = nil
  app.define_singleton_method(:find_file) { |file| opened_file = file }

  app.vc_status_open_file

  assert_nil opened_file
end
