localFlake: {...}: {
  imports = [
    localFlake.inputs.actions-nix.flakeModules.default
    localFlake.inputs.flake-root.flakeModule
    localFlake.inputs.git-hooks-nix.flakeModule
    localFlake.inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      programs = {
        actionlint.enable = true;
        alejandra.enable = true;
        deadnix.enable = true;
        mdformat.enable = true;
        shfmt.enable = true;
        statix.enable = true;
        typos = {
          enable = true;
          excludes = ["*.png"];
          configFile = let
            tomlConfig = '''';
            tomlFile = pkgs.writeText "typos.toml" tomlConfig;
          in
            toString tomlFile;
        };
      };
    };

    devShells.default = pkgs.mkShell {
      name = "Flake Dev Shell";
      buildInputs =
        [
          pkgs.rage
          pkgs.sops
          config.treefmt.build.wrapper
        ]
        ++ (pkgs.lib.attrValues config.treefmt.build.programs);

      shellHook = ''
        ${config.pre-commit.installationScript}
        echo 1>&2 "Welcome!"
      '';
    };

    pre-commit.settings.hooks = {
      check-added-large-files.enable = true;
      check-case-conflicts.enable = true;
      check-merge-conflicts.enable = true;
      commitizen.enable = true;
      end-of-file-fixer.enable = true;
      fix-byte-order-marker.enable = true;
      mixed-line-endings.enable = true;
      trufflehog.enable = true;
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
  flake.actions-nix = {
    # nix run .#render-workflows
    pre-commit.enable = false;

    defaultValues.jobs = {
      runs-on = "ubuntu-latest";
      timeout-minutes = 30;
    };

    workflows = let
      commonSteps = [
        {
          name = "Checkout Repository Code";
          uses = "actions/checkout@v4";
        }
        {
          name = "Install Nix Package Manager";
          uses = "DeterminateSystems/nix-installer-action@main";
        }
        {
          name = "Cache Nix Dependencies";
          uses = "DeterminateSystems/magic-nix-cache-action@main";
        }
      ];
    in {
      ".github/workflows/nix-flake-check.yaml" = {
        name = "Nix: Flake Check";
        on = {
          push.branches = ["master"];
          workflow_dispatch = null;
        };
        permissions.contents = "read";
        jobs.nix-flake-check.steps =
          commonSteps
          ++ [
            {
              name = "Flake checker";
              uses = "DeterminateSystems/flake-checker-action@main";
            }
          ];
      };

      ".github/workflows/nix-flake-lock.yaml" = {
        name = "Nix: Flake Lock";
        on = {
          schedule = [{cron = "0 8 * * 1,5";}];
          workflow_dispatch = null;
        };
        jobs.nix-lock-update = {
          permissions = {
            contents = "write";
            pull-requests = "write";
          };
          steps =
            commonSteps
            ++ [
              {
                name = "Update flake.lock";
                uses = "DeterminateSystems/update-flake-lock@main";
                "with" = {
                  pr-title = "chore: update flake.lock";
                  pr-labels = "dependencies\nautomated";
                };
              }
            ];
        };
      };
    };
  };
}
