{
  description = "Example of calling into Rust from Tcl";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cargoTomlContents = fromTOML (builtins.readFile ./Cargo.toml);
        excludeIncompatiblePkgs = flake-utils.lib.filterPackages system;
      in {
        packages = excludeIncompatiblePkgs rec {
          default = pkgs.callPackage ./default.nix {};
        };

        devShells = {
          # Use `nix develop '.#rustOnly'` to do Rust development
          # without relying on the final Tcl package build.
          rustOnly = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              rustc
              cargo
              rustfmt
              clippy
              rust-analyzer
              libiconv
              tcl
              pkg-config
              rustPlatform.bindgenHook
            ];
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };

          # Use `nix develop` to test out the resulting Tcl package.
          default = pkgs.mkShell {
            nativeBuildInputs = self.devShells.${system}.rustOnly.nativeBuildInputs ++ [
              self.packages.${system}.default
            ];
          };
        };
      });
}
