//! Module-level documentation.

/// A type used to preview Rust lexer styles.
#[derive(Debug, Clone)]
struct Greeter<'a> {
    name: &'a str,
    count: u32,
}

impl<'a> Greeter<'a> {
    fn message(&self) -> String {
        let ordinary = "hello\nworld";
        let raw = r#"raw "quoted" string"#;
        let bytes = b"byte string";
        let raw_bytes = br#"raw bytes"#;
        format!("{ordinary}: {} {} {:?} {:?}", self.name, raw, bytes, raw_bytes)
    }
}

macro_rules! preview {
    ($value:expr) => { println!("{:?}", $value) };
}

fn main() {
    let greeter = Greeter { name: "mrbmacs", count: 17_u32 };
    preview!(greeter.message());
    let character = 'λ';
    let byte = b'x';
    println!("{character} {byte}");
}

// Intentionally unterminated string for SCE_RUST_LEXERROR.
const BROKEN: &str = "unterminated
