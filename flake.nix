{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, nixpkgs, opam-nix }: rec{

    a=let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;


        # package = "myPro";
        on = opam-nix.lib.x86_64-linux;
        scope = on.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; };
        filterForDerivations = list: builtins.filter pkgs.lib.isDerivation list;
        scope' = filterForDerivations (builtins.attrValues scope);
    in
     pkgs.buildEnv {
          name = "ocaml-environment";
          paths = with pkgs; [ 
          # ocaml 
          # dune_3
          # ocamlformat 
          # ocamlPackages.findlib 
        ] ++ scope';
        };




    devShells.x86_64-linux.default =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;


        on = opam-nix.lib.x86_64-linux;
        scope = on.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; };
        filterForDerivations = list: builtins.filter pkgs.lib.isDerivation list;
        scope' = filterForDerivations (builtins.attrValues scope);


        ocamlEnvironment = pkgs.buildEnv {
          name = "ocaml-environment";
          # paths = with pkgs; [ 
          # # ocamlPackages.findlib 
          # ] ++ scope';

          paths = scope';
        };

      in
      with nixpkgs.legacyPackages.x86_64-linux; mkShell rec {
        # inputsFrom = [ scope.myPro ];
        buildInputs = with ocamlPackages; [ ocamlEnvironment pkgs.libev];
        # buildInputs = scope';

        shellHook = ''
          export OCAMLPATH="${ocamlEnvironment}/lib/ocaml/${ocaml.version}/site-lib"
          export OCAMLPATH="${ocamlEnvironment}/lib/ocaml/5.1.0/site-lib"
          echo    $OCAMLPATH
          export NIX_PATH=nixpkgs=${nixpkgs}:$NIX_PATH
        '';
      };


    # a = (opam-nix.lib.x86_64-linux.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; });
    b = (nixpkgs.legacyPackages.x86_64-linux.lib.getAttr a);
    aa = (opam-nix.lib.x86_64-linux.buildOpamProject { } ./. { ocaml-base-compiler = "*"; });
    aaa = a.overrideScope' { };
    packages.x86_64-linux.default = (opam-nix.lib.x86_64-linux.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; }).myPro;
    apps.x86_64-linux.default = { type = "app"; program = "${packages.x86_64-linux.default}/bin/main"; };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

