"""Python syntax style preview for mrbmacs.

Open this file in Python mode when reviewing a theme or lexer profile. The
final unterminated string is intentional, so this file is not for execution.
"""

from dataclasses import dataclass


@dataclass
class StylePreview:
    name: str = "mrbmacs"
    count: int = 1_000

    async def render(self, enabled: bool = True) -> dict[str, object]:
        number = 0b1010 + 0o17 + 0x2A + 3.14e2
        plain = "double quoted"
        character = 'single quoted'
        raw = r"raw\nstring"
        byte_string = b"bytes"
        formatted = f"{self.name=}: {number:.2f}"
        triple = """triple quoted
        documentation or multiline text
        """

        values = [plain, character, raw, byte_string, formatted, triple]
        mapping = {"enabled": enabled, "values": values}

        if enabled and number >= 42:
            await self.output(mapping)
        else:
            raise ValueError("preview disabled")

        return mapping

    async def output(self, value: object) -> None:
        print(value)


# Intentional lexer error: exercises SCE_P_STRINGEOL at the end of the file.
unterminated = "python lexer error
