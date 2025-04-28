localFlake:

{ ... }:
{
  imports = [
    localFlake.inputs.devshell.flakeModule
    localFlake.inputs.flake-root.flakeModule
    localFlake.inputs.git-hooks-nix.flakeModule
    localFlake.inputs.treefmt-nix.flakeModule
  ];
  perSystem =
    { pkgs, config, ... }:
    {
      # Formatting configuration
      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        flakeCheck = false;
        programs = {
          actionlint = {
            enable = true;
          };
          deadnix = {
            enable = true;
          };
          mdformat = {
            enable = true;
          };
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          shfmt = {
            enable = true;
          };
          statix = {
            enable = true;
          };
          typos = {
            enable = true;
            excludes = [
              "*.png"
              "*.yaml"
              "nvf.nix"
            ];
          };
          yamlfmt = {
            enable = true;
          };
        };
      };

      # Development shell environment
      devshells.default = {
        name = "NIX UTILITY ENV";
        motd = "";
        packages = [
          pkgs.rage
          pkgs.sops
          config.treefmt.build.wrapper
        ] ++ (pkgs.lib.attrValues config.treefmt.build.programs);
      };

      # Pre-commit hook configuration
      pre-commit.settings.hooks = {
        statix = {
          enable = true;
          package = config.treefmt.build.programs.statix;
        };
        treefmt = {
          enable = true;
          package = config.treefmt.build.wrapper;
        };
      };
    };
}
