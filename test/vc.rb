assert('VC.new') do
  vcinfo = Mrbmacs::VC.new(File.dirname(__FILE__))
  assert_kind_of(Mrbmacs::VC, vcinfo)
end

assert('VC.to_s') do
  vcinfo = Mrbmacs::VC.new(File.dirname(__FILE__))
  assert_kind_of(String, vcinfo.to_s)
end
