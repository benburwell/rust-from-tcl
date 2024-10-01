# Calling Rust code from Tcl

This is a demo of how to build a Rust library which can be invoked from within a
Tcl program.

The [`tcltk`][oooutlk] library is used to expose Rust functions as Tcl commands.
The top-level `src/lib.rs` file provides the Tcl interface, while the actual
Rust API lives in `src/greeter.rs`.

## Building and running

Using the Nix shell for development is recommended. There are two development
shells provided by `flake.nix`.

Generally, `nix develop` is what you'll want. It will give you:
- A Rust compiler and associated tooling
- `tclsh`
- The final product, a Tcl package called `greeter`, which you can `package
  require` as you'd expect.

From within this default dev shell, you can experiment with calls to `greeter`
and execute the sample `test.tcl` program:

```
~/src/rust-from-tcl$ nix develop
fa-BenBurwell:rust-from-tcl ben.burwell$ tclsh test.tcl 
Hello, world!
Bonjour, world!
Hola, world!
```

If you need to tweak things about the Rust build without depending on a finished
Tcl package (e.g. to fix something broken), you can use `nix develop
'.#rustOnly'`. You'll still get the Rust toolchain, but you won't be able to
`package require greeter` from Tcl.

[oooutlk]: https://github.com/oooutlk/tcltk
