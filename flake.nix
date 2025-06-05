{
  description = "Minimal unikernel development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        solo5 = pkgs.stdenv.mkDerivation rec {
	  pname = "solo5";
	  version = "0.9.1";
          

	  src = pkgs.fetchFromGitHub {
	    owner = "Solo5";
	    repo = "solo5";
	    rev = "v${version}";
	    sha256 = "...";

	    nativeBuildInputs = [pkgs.pkg-config];
	    buildInputs = [pkgs.libseccomp];
	    configurePhase = "./configure.sh";
	    buildPhase = "make";
	    InstallPhase = "cp solo5-spt $out/bin/";
	  };
	};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Basic build tools
            gcc
            gnumake
            pkg-config
            git
	    libseccomp # reqired for the Solo5
	    solo5            
            # Container tools
            docker
          ];
          
          shellHook = ''
            echo "🦄 Minimal unikernel environment ready"
          '';
        };
      });
}
