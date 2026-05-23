module Mrbmacs
  class Test1Extension < Extension
  end

  class Test2Extension < Extension
  end
end

assert("subclasses") do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal(3, Mrbmacs::Extension.subclasses.size)
end
