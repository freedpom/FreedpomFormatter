{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
in

{
  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        pkgs,
        ...
      }:
      {
        config = {
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
    );
  };
}
