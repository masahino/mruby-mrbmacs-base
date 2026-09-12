module Mrbmacs
  class LayoutTestPane
    attr_accessor :parent
  end
end

assert('TabLayout keeps panes in tree order') do
  first = Mrbmacs::LayoutTestPane.new
  second = Mrbmacs::LayoutTestPane.new
  tab = Mrbmacs::TabLayout.new(first)

  split = tab.split(first, second, :horizontal)

  assert_equal([first, second], tab.panes)
  assert_equal(split, first.parent)
  assert_equal(split, second.parent)
  assert_equal(split, tab.layout_root)
end

assert('TabLayout deletes a pane and promotes its sibling') do
  first = Mrbmacs::LayoutTestPane.new
  second = Mrbmacs::LayoutTestPane.new
  tab = Mrbmacs::TabLayout.new(first)
  tab.split(first, second, :vertical)

  survivor = tab.delete(first)

  assert_equal(second, survivor)
  assert_equal([second], tab.panes)
  assert_equal(nil, second.parent)
end

assert('TabLayout keeps one pane') do
  first = Mrbmacs::LayoutTestPane.new
  second = Mrbmacs::LayoutTestPane.new
  tab = Mrbmacs::TabLayout.new(first)
  tab.split(first, second, :horizontal)

  tab.keep_only(second)

  assert_equal([second], tab.panes)
  assert_equal(second, tab.active_pane)
  assert_equal(nil, second.parent)
end
