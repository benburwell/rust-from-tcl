{
  stdenv,
  rustPlatform,
  tcl,
  pkg-config,
}:
let
  cargoTomlContents = fromTOML (builtins.readFile ./Cargo.toml);

  sharedLib = rustPlatform.buildRustPackage {
    pname = cargoTomlContents.package.name;
    version = cargoTomlContents.package.version;
    src = ./.;
    propagatedBuildInputs = [ tcl ];
    nativeBuildInputs = [
      pkg-config
      rustPlatform.bindgenHook
    ];
    cargoLock = {
      allowBuiltinFetchGit = true;
      lockFile = ./Cargo.lock;
    };
  };

  libName = "lib${cargoTomlContents.package.name}${stdenv.hostPlatform.extensions.sharedLibrary}";
in tcl.mkTclDerivation {
  pname = cargoTomlContents.package.name;
  version = cargoTomlContents.package.version;
  src = ./.;

  buildInputs = [ sharedLib ];
  nativeBuildInputs = [ tcl.tclPackageHook ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/$pname"
    cp "${sharedLib}/lib/${libName}" "$out/lib/$pname/${libName}"
    echo "pkg_mkIndex $out/lib/$pname" | ${tcl}/bin/tclsh
    runHook postInstall
  '';
}
