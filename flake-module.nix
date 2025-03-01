{ inputs, ... }:
{

  imports = [

    inputs.flake-parts.flakeModules.flakeModules
    inputs.treefmt-nix.flakeModule
    inputs.devshell.flakeModule
    inputs.flake-root.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        flakeCheck = false;
        programs = {
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          statix.enable = true;
          deadnix.enable = true;

          actionlint.enable = true;
          mdformat.enable = true;
          yamlfmt.enable = true;
          shfmt.enable = true;
        };
      };

      devshells.default = {
        name = "NixOS Utility Environment";
        motd = "";
        packages = [
          pkgs.nil
          pkgs.nixd
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
