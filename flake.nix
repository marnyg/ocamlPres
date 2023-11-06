{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, nixpkgs, opam-nix }: rec{
    devShells.x86_64-linux.default =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        on = opam-nix.lib.x86_64-linux;
        scope = on.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; };
        filterForDerivations = list: builtins.filter pkgs.lib.isDerivation list;
        scope' = filterForDerivations (builtins.attrValues scope);

        joinedOcamlPath = pkgs.symlinkJoin { name = "ocamlLibs"; paths = scope'; };
      in
      with nixpkgs.legacyPackages.x86_64-linux; mkShell rec {
        buildInputs = scope' ++ [ pkgs.libev pkgs.nixd pkgs.rnix-lsp ];
        LSP_SERVERS = "ocamllsp, rnix, nixd";

        shellHook = ''
          export OCAMLPATH="${joinedOcamlPath}/lib/ocaml/${scope.ocaml.version}/site-lib"
          export NIX_PATH=nixpkgs=${nixpkgs}:$NIX_PATH
        '';
      };

    packages.x86_64-linux.default = (opam-nix.lib.x86_64-linux.buildOpamProject' { } ./. { ocaml-base-compiler = "*"; }).myPro;
    apps.x86_64-linux.default = { type = "app"; program = "${packages.x86_64-linux.default}/bin/main"; };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}

