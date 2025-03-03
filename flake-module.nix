localFlake:

{ lib, config, self, pkgs, ... }:
{
  imports = [
    localFlake.inputs.treefmt-nix.flakeModule
    localFlake.inputs.devshell.flakeModule
    localFlake.inputs.flake-root.flakeModule
    localFlake.inputs.git-hooks-nix.flakeModule
    localFlake.inputs.home-manager.flakeModules.home-manager
  ];
  perSystem = { system, ... }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      programs = {
        # Nix formatting tools
        nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rfc-style;
        };
        statix.enable = true; # Static analysis for Nix
        deadnix.enable = true; # Detect dead code in Nix

        typos.enable = true;
        typos.excludes = [
          "*.png"
          "*.yaml"
        ];

        # Additional formatters
        actionlint.enable = true; # GitHub Actions linter
        mdformat.enable = true; # Markdown formatter
        yamlfmt.enable = true;
        shfmt.enable = true;
      };
    };
  };
}
