{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      vhs = pkgs.buildGoModule {
        pname = "vhs";
        version = "0.2.0";

        src = pkgs.fetchFromGitHub {
          owner = "charmbracelet";
          repo = "vhs";
          rev = "v0.2.0";
          hash = "sha256-t6n4uID7KTu/BqsmndJOft0ifxZNfv9lfqlzFX0ApKw=";
        };

        vendorHash = "sha256-9nkRr5Jh1nbI+XXbPj9KB0ZbLybv5JUVovpB311fO38=";
      };

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          actionlint.enable = true;
          alejandra.enable = true;
          prettier.enable = true;
        };
      };
    in {
      devShells = {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = [
            pkgs.chromium
            pkgs.ffmpeg
            pkgs.ttyd
            vhs
          ];
          nativeBuildInputs = [];

          inherit (pre-commit-check) shellHook;
        };
      };
    });
}
