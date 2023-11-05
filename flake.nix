{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, nixpkgs, opam-nix }: rec{
    devShells.x86_64-linux.default =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;


        package = "myPro";
        on = opam-nix.lib.x86_64-linux;
        scope = on.buildOpamProject { } package ./. { ocaml-base-compiler = "*"; };
        devPackagesQuery = {

          # You can add "development" packages here. They will get added to the devShell automatically.
          # ocaml-lsp-server = "*";
          # ocamlformat = "*";
        };
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);


        ocamlEnvironment = pkgs.buildEnv {
          name = "ocaml-environment";
          paths = with pkgs; [
            ocaml
            dune_3
            ocamlformat
            ocamlPackages.findlib
            # ocamlPackages.core
            # ocamlPackages.dream
            # ocamlPackages.tyxml
            # ocamlPackages.alcotest
            # ocamlPackages.ppx_inline_test
            # ];
          ] ++ devPackages;
        };
      in
      with nixpkgs.legacyPackages.x86_64-linux; mkShell rec {
        name = "myPro-dev";
        buildInputs = with ocamlPackages; [
          ocamlEnvironment
        ];

        shellHook = ''
          export OCAMLPATH="${ocamlEnvironment}/lib/ocaml/${ocaml.version}/site-lib"
          echo    $OCAMLPATH
          export NIX_PATH=nixpkgs=${nixpkgs}:$NIX_PATH
        '';
      };


    a=(opam-nix.lib.x86_64-linux.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; }).myPro;
    packages.x86_64-linux.default = (opam-nix.lib.x86_64-linux.buildOpamProject'  {} ./. { ocaml-base-compiler = "*"; }).myPro;
    # packages.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; ocamlPackages.buildDunePackage rec {
    #   pname = "myPro";
    #   version = "0.1.0";
    #   duneVersion = "3";
    #   src = ./.;
    #
    #   buildInputs = [
    #     ocamlPackages.core
    #     ocamlPackages.dream
    #     ocamlPackages.tyxml
    #     ocamlPackages.alcotest
    #     ocamlPackages.ppx_inline_test
    #   ];
    #
    #   #useDuneConfig = true; # Use this to read dependencies from .opam file
    #   doCheck = true;
    #   checkTarget = "test";
    #
    #   #preBuild = ''dune build myPro.opam '';
    # };
    apps.x86_64-linux.default = { type = "app"; program = "${packages.x86_64-linux.default}/bin/main"; };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

