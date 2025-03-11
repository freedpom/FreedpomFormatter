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
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          statix = {
            enable = true;
          };
          deadnix = {
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

          actionlint = {
            enable = true;
          };
          mdformat = {
            enable = true;
          };
          yamlfmt = {
            enable = true;
          };
          shfmt = {
            enable = true;
          };
        };
      };

      devshells.default = {
        name = "NIX UTILITY ENV";
        motd = "";
        packages = [
          pkgs.rage
          pkgs.sops
          config.treefmt.build.wrapper
        ] ++ (pkgs.lib.attrValues config.treefmt.build.programs);
      };

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
