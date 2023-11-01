{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

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

    packages.x86_64-linux.default= with nixpkgs.legacyPackages.x86_64-linux; ocamlPackages.buildDunePackage rec {
      pname = "myPro";
      version = "0.1.0";
      duneVersion = "3";
      src = ./.;

      buildInputs = [
        ocamlPackages.core
        ocamlPackages.dream
        ocamlPackages.tyxml
        ocamlPackages.alcotest
        ocamlPackages.ppx_inline_test
      ];
      strictDeps = true;

      useDuneConfig = true; # Use this to read dependencies from .opam file
      doCheck = true;
      checkTarget = "test";

      #preBuild = ''dune build myPro.opam '';
    };
    apps.x86_64-linux.default= { type = "app"; program = "${packages.x86_64-linux.default}/bin/main"; };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

