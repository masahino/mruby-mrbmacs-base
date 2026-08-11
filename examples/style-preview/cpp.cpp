#include <cstdint>
#include <string>

#define MRBMACS_VERSION 17

// Line comment and TODO task marker.
/// Documentation for the preview type.
class StylePreview final {
public:
  using Count = std::uint32_t;

  explicit StylePreview(std::string name) : name_(std::move(name)) {}

  [[nodiscard]] std::string message() const {
    const Count count = 0x2Au;
    const char escaped = '\n';
    const auto ordinary = "hello\tworld";
    const auto raw = R"tag(raw "string" text)tag";
    return name_ + ordinary + raw + std::to_string(count + MRBMACS_VERSION);
  }

private:
  std::string name_;
};

/** @brief Main entry point. */
int main() {
  StylePreview preview{"mrbmacs"};
  return preview.message().empty() ? 1 : 0;
}

// Intentionally unfinished string to expose the lexer error style.
const char *unfinished = "preview
