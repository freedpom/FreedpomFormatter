{
  description = "Formatting Nix code with the freedom of a thousand eagles";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      _:
      let
        inherit (flake-parts.lib) importApply;
        flakeModule = importApply ./fmt-module.nix;
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = [
          flakeModule
        ];

        flake = {
          inherit flakeModule;
        };
      }
    );
}
