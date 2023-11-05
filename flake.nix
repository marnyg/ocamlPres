{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

  outputs =
    { self, nixpkgs }: rec{
      #   devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; mkShell  rec {
      #   
      #     nativeBuildInputds=[
      #       ocamlPackages.findlib
      #       ocaml
      #       dune_3
      #     ];
      #     buildInputs = [
      #       ocamlPackages.ocaml-lsp
      #       ocaml
      #       dune_3
      #       opam
      #       openssl
      #       ocamlformat
      #       libev
      #       pkg-config
      #       ocamlPackages.findlib
      #       ocamlPackages.core
      #       ocamlpackages.dream
      #       ocamlpackages.tyxml
      #       ocamlPackages.alcotest
      #       ocamlPackages.ppx_inline_test
      #       ocamlPackages.ppxlib
      #       ocamlPackages.base
      #     ];
      #       shellHook = ''
      #   export OCAMLPATH=""
      #
      #   addToOCamlPath() {
      #     local lib_path="$1/lib/ocaml/${ocaml.version}/site-lib"
      #     if [[ -d "$lib_path" ]]; then
      #       if [[ -z "$OCAMLPATH" ]]; then
      #         export OCAMLPATH="$lib_path"
      #       else
      #         export OCAMLPATH="$OCAMLPATH:$lib_path"
      #       fi
      #     fi
      #   }
      #
      #   for pkg in ${toString buildInputs}; do
      #     addToOCamlPath $pkg
      #   done
      #
      #   echo "OCAMLPATH is set to $OCAMLPATH"
      # '';
      #     # shellHook = '' 
      #     #   #opam switch create my_switch2 4.14.1 || opam switch my_switch2
      #     #   #eval $(opam env)
      #     #   #opam install . --deps-only
      #     # '';
      #     LSP_SERVERS="ocamllsp";
      #   };
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          ocamlEnvironment = pkgs.buildEnv {
            name = "ocaml-environment";
            paths = with pkgs; [
              ocaml
              dune_3
              ocamlformat
              ocamlPackages.findlib
              ocamlPackages.core
              ocamlPackages.dream
              ocamlPackages.tyxml
              ocamlPackages.alcotest
              ocamlPackages.ppx_inline_test
            ];
          };
        in
        with nixpkgs.legacyPackages.x86_64-linux; mkShell rec {
          name = "myPro-dev";
          buildInputs = with ocamlPackages; [ ocamlEnvironment ];

          shellHook = ''
            export OCAMLPATH="${ocamlEnvironment}/lib/ocaml/${ocaml.version}/site-lib"
            echo    $OCAMLPATH
          '';
        };

      packages.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; ocamlPackages.buildDunePackage rec {
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

        #useDuneConfig = true; # Use this to read dependencies from .opam file
        doCheck = true;
        checkTarget = "test";

        #preBuild = ''dune build myPro.opam '';
      };
      apps.x86_64-linux.default = { type = "app"; program = "${packages.x86_64-linux.default}/bin/main"; };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}

