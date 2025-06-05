{
  description = "Minimal unikernel development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Basic build tools
            gcc
            gnumake
            pkg-config
            git
            
            # Container tools
            docker
          ];
          
          shellHook = ''
            echo "🦄 Minimal unikernel environment ready"
          '';
        };
      });
}
