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

  app.vc_refresh_gutter

  assert_equal 3, messages.count { |message| message == Scintilla::SCI_MARKERDELETEALL } - before_delete
  assert_equal 4, messages.count { |message| message == Scintilla::SCI_MARKERADD } - before_add
end
