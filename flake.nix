{
  description = "kat's ~/src";
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    katgba = {
      url = "github:kittywitch/katgba/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };
    srcprv = {
      url = "git+ssh://git@github.com/kittywitch/srcprv?ref=main";
    };
  };

  outputs = {
    self,
    flake-utils,
    katgba,
    nixpkgs,
    nur,
    ...
  } @ inputs: let
    eachSystemOutputs = flake-utils.lib.eachDefaultSystem (system: rec {
      overlays.default = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.overlays.default
          overlays.default
          (final: prev: {
              katgba = katgba.packages.${system}.katgba;
              katgba-emu = katgba.packages.${system}.katgba-emu;
          })
        ];
      };
      devShells.default = import ./shell.nix {inherit pkgs;};
      packages = {
        katgba = pkgs.katgba;
        fetchdps = pkgs.fetchdps;
        katgba-emu = pkgs.katgba-emu;
      };
    });
    formatting = import ./formatting.nix {inherit inputs;};
  in
    eachSystemOutputs
    // rec {
      inherit (formatting) formatter;
      inherit inputs;
    };
}
