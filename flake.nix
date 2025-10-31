{
  description = "Nix Docker Layered Image test.";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, naersk, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = (import nixpkgs) {
            inherit system;
          };

          naersk' = pkgs.callPackage naersk {};

        in rec {

          packages = {
            app = naersk'.buildPackage {
              src = ./.;
            };
            default = packages.app;
            docker = pkgs.dockerTools.buildLayeredImage {
              name = "localhost/nix-test";
              tag = "latest";
              contents = [ packages.default ];
              config.Cmd = [ "${packages.default}/bin/nix-docker-test" ];
            };
          };

          # For `nix develop` (optional, can be skipped):
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ rustc cargo jujutsu ];
          };
        }
      );
}
