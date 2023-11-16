{
  description = "My OCaml project";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  inputs.opam-nix.url = "github:tweag/opam-nix";

  outputs = { self, nixpkgs, opam-nix }:
    let
      myPro = (opam-nix.lib.x86_64-linux.buildDuneProject { } "myPro" ./. { ocaml-base-compiler = "*"; }).myPro;
    in
    {
      packages.x86_64-linux.default = myPro;
      apps.x86_64-linux.default = { type = "app"; program = "${myPro}/bin/main"; };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}

