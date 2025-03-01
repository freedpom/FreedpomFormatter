{
  description = "FREEDPOM FORMAT";

  inputs = {
    devshell.url = "github:numtide/devshell"; # Development environment
    flake-parts.url = "github:hercules-ci/flake-parts"; # Flake infrastructure
    flake-root.url = "github:srid/flake-root"; # Flake infrastructure
    git-hooks-nix.url = "github:cachix/git-hooks.nix"; # Git pre-commit hooks
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Nixpkgs
    treefmt-nix.url = "github:numtide/treefmt-nix"; # Code formatting and linting
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./flake-module.nix { inherit withSystem; };
      in
      {
        imports = [
          flakeModules.default
          inputs.flake-parts.flakeModules.flakeModules
          inputs.treefmt-nix.flakeModule
          inputs.devshell.flakeModule
          inputs.flake-root.flakeModule
          inputs.git-hooks-nix.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        flake = {
          inherit flakeModules;
        };
      }
    );
}
