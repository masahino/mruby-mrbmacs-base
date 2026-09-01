assert('search highlight is inactive until begun') do
  app = Mrbmacs::TestSupport::Application.new
  assert_false app.search_highlight_active?
end

assert('search_highlight_begin with text activates, blank clears') do
  app = Mrbmacs::TestSupport::Application.new

  app.search_highlight_begin('foo')
  assert_true app.search_highlight_active?

  app.search_highlight_begin('')
  assert_false app.search_highlight_active?
end

assert('search_highlight_end clears the indicator and deactivates') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  app.search_highlight_begin('foo')
  view.messages.clear

  app.search_highlight_end

  assert_false app.search_highlight_active?
  assert_true view.messages.include?(Scintilla::SCI_SETINDICATORCURRENT)
  assert_true view.messages.include?(Scintilla::SCI_INDICATORCLEARRANGE)
end

assert('refresh_search_highlight restores the target range') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  view.test_return[Scintilla::SCI_GETTARGETSTART] = 11
  view.test_return[Scintilla::SCI_GETTARGETEND] = 22
  view.test_return[Scintilla::SCI_SEARCHINTARGET] = -1

  app.search_highlight_begin('foo')

  target_writes = view.messages.count do |id|
    id == Scintilla::SCI_SETTARGETSTART || id == Scintilla::SCI_SETTARGETEND
  end
  assert_true target_writes >= 2
end

assert('refresh_search_highlight is a no-op when inactive') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  view.messages.clear

  app.refresh_search_highlight

  assert_false view.messages.include?(Scintilla::SCI_INDICATORFILLRANGE)
end

assert('refresh_search_highlight clears the indicator off the current selection') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  view.test_return[Scintilla::SCI_GETSELECTIONSTART] = 3
  view.test_return[Scintilla::SCI_GETSELECTIONEND] = 8
  app.search_highlight_begin('foo')
  view.messages.clear

  app.refresh_search_highlight

  # one clear for the whole range, one for the selection
  clears = view.messages.count { |m| m == Scintilla::SCI_INDICATORCLEARRANGE }
  assert_true clears >= 2
end

assert('modeline_search is empty unless a search is running') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '', app.modeline_search

  app.search_highlight_begin('foo')
  assert_true app.modeline_search.include?('isearch')

  app.search_highlight_begin('bar', :replace)
  assert_true app.modeline_search.include?('replace')

  app.search_highlight_end
  assert_equal '', app.modeline_search
end
