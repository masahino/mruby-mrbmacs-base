package preview;

import java.util.List;
import java.util.Optional;

/**
 * Demonstrates Java styles and a {@link List} documentation link.
 * @param <T> stored value type
 */
public final class StylePreview<T extends Number> {
    private static final int VERSION = 17;
    private final T value;

    public StylePreview(T value) {
        this.value = value;
    }

    public Optional<String> message(boolean enabled) {
        if (!enabled) {
            return Optional.empty();
        }
        String escaped = "hello\nworld";
        String block = """
                Java text block
                """;
        return Optional.of(escaped + block + value + VERSION);
    }

    public static void main(String[] args) {
        var preview = new StylePreview<>(42);
        preview.message(true).ifPresent(System.out::println);
    }
}

// TODO: task-marker styling.
String unfinished = "preview
