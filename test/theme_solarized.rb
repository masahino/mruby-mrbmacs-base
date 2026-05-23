module Mrbmacs
  # Test theme
  class TestTheme < SolarizedTheme
    @@theme_name = 'test-theme'
    def initialize
      super
      @name = @@theme_name
      @foreground_color = @@base0
    end

    def set_pallete
      @@base0 = 0x010203
    end
  end
end

assert('SolarizedDarkTheme') do
  dark = Mrbmacs::SolarizedDarkTheme.new
  assert_equal('solarized-dark', dark.name)
  assert_equal(0x969483, dark.foreground_color)
  assert_equal(0x362b00, dark.background_color)
end

assert('SolarizedLightTheme') do
  light = Mrbmacs::SolarizedLightTheme.new
  assert_equal('solarized-light', light.name)
  assert_equal(0x969583, light.foreground_color)
  assert_equal(0xe3f6fd, light.background_color)
end

assert('set_pallete') do
  test = Mrbmacs::TestTheme.new
  assert_equal('test-theme', test.name)
  assert_equal(0x010203, test.foreground_color)
end
