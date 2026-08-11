assert('StyleSpec converts legacy arrays') do
  style = Mrbmacs::StyleSpec.from_legacy([1, 2, true, false])
  assert_equal 1, style.foreground
  assert_equal 2, style.background
  assert_equal true, style.italic
  assert_equal false, style.bold
end

assert('StyleSpec merges partial overrides') do
  base = Mrbmacs::StyleSpec.new(foreground: 1, background: 2, italic: true, bold: false)
  merged = base.merge(Mrbmacs::StyleSpec.new(italic: false, bold: true))
  assert_equal 1, merged.foreground
  assert_equal 2, merged.background
  assert_equal false, merged.italic
  assert_equal true, merged.bold
end
