assert('StyleRole normalizes legacy role names') do
  assert_equal :function_name, Mrbmacs::StyleRole.normalize(:color_function_name)
  assert_equal :comment, Mrbmacs::StyleRole.normalize(:color_comment)
end

assert('StyleRole returns Emacs-compatible fallback chain') do
  assert_equal [:property_use, :property_name, :variable_name, :default],
               Mrbmacs::StyleRole.ancestors(:property_use)
  assert_equal [:number, :constant, :default], Mrbmacs::StyleRole.ancestors(:number)
end
