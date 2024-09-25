use tcl::reexport_clib::{Tcl_Interp, TCL_OK};
use tcl::*;
use tcl_derive::proc;
use version::version;

mod greeter;

#[derive(thiserror::Error, Debug)]
enum Error {
    #[error("unsupported language")]
    UnsupportedLanguage,
}

/// Initialize the Tcl module.
///
/// # Safety
///
/// This function uses unsafe calls to Tcl's C library.
#[no_mangle]
pub unsafe extern "C" fn Greeter_Init(interp: *mut Tcl_Interp) -> u32 {
    let interp = Interp::from_raw(interp).expect("No interpreter");
    interp.def_proc("::greeter::greet", greet as ObjCmdProc);
    interp.package_provide("greeter", version!());
    TCL_OK
}

#[proc]
fn greet(who: String, lang: String) -> Result<String, Box<dyn std::error::Error>> {
    let lang = match lang.as_str() {
        "en" => greeter::Language::English,
        "fr" => greeter::Language::French,
        "es" => greeter::Language::Spanish,
        _ => return Err(Box::new(Error::UnsupportedLanguage)),
    };
    Ok(greeter::greet(&who, lang))
}

#[cfg(test)]
mod tests {
    use super::*;
    use tcl::Interpreter;

    fn setup_interpreter() -> Interpreter {
        let interp = Interpreter::new().expect("Could not create interpreter");
        unsafe {
            Greeter_Init(interp.as_ptr());
        }
        interp
    }

    #[test]
    fn test_greeting_english() {
        let interp = setup_interpreter();
        let code = "
            ::greeter::greet Alice en
        ";
        assert_eq!("Hello, Alice!", interp.eval(code).unwrap().get_string());
    }

    #[test]
    fn test_greeting_unknown() {
        let interp = setup_interpreter();
        let code = "
            ::greeter::greet Alice xx
        ";
        assert!(interp.eval(code).is_err());
    }
}
