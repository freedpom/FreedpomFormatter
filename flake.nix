{
  description = "Description for the project";

  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    devshell.url = "github:numtide/devshell";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    # Flake infrastructure
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        withSystem,
        flake-parts-lib,
        config,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./flake-module.nix { inherit withSystem inputs config; };
      in
      {
        imports = [
          flakeModules.default
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem =
          _:
          {

          };
        flake = {
          inherit flakeModules;
        };
      }
    );
}
