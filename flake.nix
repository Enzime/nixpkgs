{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem = { config, pkgs, ... }: {
        packages.default = pkgs.writeShellApplication {
          name = "clone-nixpkgs";
          text = ''
            git clone https://github.com/Enzime/nixpkgs nixpkgs
            cd nixpkgs
            git switch -d
            git branch -d master
            git remote rename origin fork
            git worktree add ../.nixpkgs-config fork
            cp ../.nixpkgs-config/config.to-copy .git/config
            git fetch --all
            git switch -d upstream
            jj git init --colocate
            ln -s ../../../.nixpkgs-config/config.toml .jj/repo/config.toml
            jj git fetch
          '';
        };
      };
    };
}
