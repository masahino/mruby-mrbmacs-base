module Mrbmacs
  # Application method for message
  class Application
    def message(text)
      @logger.info text
      refresh_messages_buffer
      @frame.echo_puts text
    end
  end
end
