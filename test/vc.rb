def vc_runner(results)
  proc do |_directory, command|
    results[command] || ['', 1]
  end
end

assert('VC managed repository') do
  runner = vc_runner(
    'rev-parse --show-toplevel' => ["/work/project\n", 0],
    'symbolic-ref --quiet --short HEAD' => ["main\n", 0]
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
    'rev-parse --show-toplevel' => ["/work/project\n", 0],
    'symbolic-ref --quiet --short HEAD' => ['', 1],
    'rev-parse --short HEAD' => ["1a2b3c4\n", 0]
  )
  vcinfo = Mrbmacs::VC.new('.', runner)

  assert_true vcinfo.detached?
  assert_equal '@1a2b3c4', vcinfo.branch
  assert_equal 'Git:@1a2b3c4', vcinfo.to_s
end

assert('VC unmanaged directory') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner('rev-parse --show-toplevel' => ['', 128]))

  assert_false vcinfo.managed?
  assert_equal :unmanaged, vcinfo.state
  assert_equal '', vcinfo.to_s
end

assert('VC git unavailable') do
  vcinfo = Mrbmacs::VC.new('.', vc_runner('rev-parse --show-toplevel' => ['', 127]))

  assert_false vcinfo.managed?
  assert_equal :unavailable, vcinfo.state
  assert_equal '', vcinfo.to_s
end
