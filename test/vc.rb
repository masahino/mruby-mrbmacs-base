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
