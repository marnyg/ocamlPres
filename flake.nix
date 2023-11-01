{
  description = "My OCaml project";

  outputs = { self, nixpkgs }: rec {
    devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        ocamlPackages.ocaml-lsp
        ocaml
        dune_3
        opam
        openssl
        ocamlformat
        libev
        pkg-config
      ];
      shellHook = '' 
        opam switch create my_switch2 4.14.1 || opam switch my_switch2
        eval $(opam env)
        #opam install . --deps-only
      '';
      LSP_SERVERS="ocamllsp";
    };

    packages.x86_64-linux.myOcamlPackage = with nixpkgs.legacyPackages.x86_64-linux; ocamlPackages.buildDunePackage rec {
      pname = "myPro";
      version = "0.1.0";
      duneVersion = "3";
      src = ./.;

      buildInputs = [
        ocamlPackages.core
        # ocamlPackages.dream # need to as a import
        ocamlPackages.alcotest
        ocamlPackages.ppx_inline_test
      ];
      strictDeps = true;

      useDuneConfig = true; # Use this to read dependencies from .opam file
      doCheck = true;
      checkTarget = "test";

      #preBuild = ''dune build myPro.opam '';
    };
    packages.x86_64-linux.default = packages.x86_64-linux.myOcamlPackage;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

