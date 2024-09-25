use std::fmt::Debug;

#[derive(Debug)]
pub enum Language {
    English,
    French,
    Spanish,
}

/// Greet returns a greeting message in the preferred language for the provided recipient.
pub fn greet(who: &str, lang: Language) -> String {
    match lang {
        Language::English => format!("Hello, {who}!"),
        Language::French => format!("Bonjour, {who}!"),
        Language::Spanish => format!("Hola, {who}!"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_english_greeting() {
        assert_eq!(
            greet("Alice", Language::English),
            "Hello, Alice!".to_string()
        );
        assert_eq!(
            greet("Alice", Language::French),
            "Bonjour, Alice!".to_string()
        );
        assert_eq!(
            greet("Alice", Language::Spanish),
            "Hola, Alice!".to_string()
        );
    }
}
