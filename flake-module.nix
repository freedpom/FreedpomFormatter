localFlake:

{ ... }:
{
  imports = [
    localFlake.inputs.treefmt-nix.flakeModule
    localFlake.inputs.devshell.flakeModule
    localFlake.inputs.flake-root.flakeModule
    localFlake.inputs.git-hooks-nix.flakeModule
  ];
  perSystem =
    { pkgs, config, ... }:
    {
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
      # Development environment configuration
      devshells.default = {
        name = "NIX UTILITY ENV";
        motd = ""; # Message of the day
        packages = [
          pkgs.rage
          pkgs.sops
          config.treefmt.build.wrapper
        ] ++ (pkgs.lib.attrValues config.treefmt.build.programs);
      };

      # Git pre-commit hooks
      pre-commit.settings.hooks = {
        treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
        statix = {
          enable = true;
          package = config.treefmt.build.programs.statix;
        };
      };
    };
}
