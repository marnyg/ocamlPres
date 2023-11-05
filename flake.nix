{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  # inputs.opam2nix-src = {
  #     url = "https://github.com/timbertson/opam2nix/archive/v1.tar.gz";
  #     flake = false;
  #   };
  #inputs.opam-nix.url = "github:tweag/opam-nix";
  inputs.opam2nix-src = { url = "github:dwarfmaster/opam2nix"; };

  outputs = { self, nixpkgs, opam2nix-src }: rec{
    #   devshells.x86_64-linux.default = with nixpkgs.legacypackages.x86_64-linux; mkshell  rec {
    #   
    #     nativebuildinputds=[
    #       ocamlpackages.findlib
    #       ocaml
    #       dune_3
    #     ];
    #     buildinputs = [
    #       ocamlpackages.ocaml-lsp
    #       ocaml
    #       dune_3
    #       opam
    #       openssl
    #       ocamlformat
    #       libev
    #       pkg-config
    #       ocamlpackages.findlib
    #       ocamlpackages.core
    #       ocamlpackages.dream
    #       ocamlpackages.tyxml
    #       ocamlpackages.alcotest
    #       ocamlpackages.ppx_inline_test
    #       ocamlpackages.ppxlib
    #       ocamlpackages.base
    #     ];
    #       shellhook = ''
    #   export ocamlpath=""
    #
    #   addtoocamlpath() {
    #     local lib_path="$1/lib/ocaml/${ocaml.version}/site-lib"
    #     if [[ -d "$lib_path" ]]; then
    #       if [[ -z "$ocamlpath" ]]; then
    #         export ocamlpath="$lib_path"
    #       else
    #         export ocamlpath="$ocamlpath:$lib_path"
    #       fi
    #     fi
    #   }
    #
    #   for pkg in ${tostring buildinputs}; do
    #     addtoocamlpath $pkg
    #   done
    #
    #   echo "ocamlpath is set to $ocamlpath"
    # '';
    #     # shellhook = '' 
    #     #   #opam switch create my_switch2 4.14.1 || opam switch my_switch2
    #     #   #eval $(opam env)
    #     #   #opam install . --deps-only
    #     # '';
    #     lsp_servers="ocamllsp";
    #   };
    a = opam2nix-src;
    devShells.x86_64-linux.default =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        ocaml = pkgs.ocaml;
        opam2nix = import opam2nix-src { inherit pkgs; };
        selection = opam2nix.buildInputs {
          inherit ocaml;
          selection = ./opam-selection.nix;
          src = ./.;
        };

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
          # ] +selection;
        };
      in
      with nixpkgs.legacyPackages.x86_64-linux; mkShell rec {
        name = "myPro-dev";
        buildInputs = with ocamlPackages; [
          ocamlEnvironment
          opam2nix-src.outputs.defaultPackage.x86_64-linux
          selection
        ];

        shellHook = ''
          export OCAMLPATH="${ocamlEnvironment}/lib/ocaml/${ocaml.version}/site-lib"
          echo    $OCAMLPATH
          export NIX_PATH=nixpkgs=${nixpkgs}:$NIX_PATH
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

