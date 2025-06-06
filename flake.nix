{
  description = "Unikernel development environment with Solo5";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Solo5 package definition
        solo5 = pkgs.stdenv.mkDerivation rec {
          pname = "solo5";
          version = "0.9.1";

          src = pkgs.fetchurl {
	    url = "https://github.com/Solo5/solo5/releases/download/v${version}/solo5-v${version}.tar.gz";
            sha256 = "sha256-aHCY/mrEn3tNXC6e1fzzLHcrzYkKzgF7t1qc3QtnaVE=";
          };

          nativeBuildInputs = with pkgs; [ 
            pkg-config 
            which
          ];
          
          buildInputs = with pkgs; [ 
            libseccomp 
          ];

          configurePhase = ''
            ./configure.sh
          '';

          buildPhase = ''
            make -j$NIX_BUILD_CORES
          '';

          installPhase = ''
            mkdir -p $out/bin
            # Install the tenders (execution environments)
            cp tenders/spt/solo5-spt $out/bin/ 2>/dev/null || true
            cp tenders/hvt/solo5-hvt $out/bin/ 2>/dev/null || true
            # Install the elftool utility
            cp elftool/solo5-elftool $out/bin/ 2>/dev/null || true
            # Make executables
            chmod +x $out/bin/solo5-* 2>/dev/null || true
            
            # Install headers and libraries for building unikernels
            mkdir -p $out/include $out/lib
            cp -r include/* $out/include/ 2>/dev/null || true
            find bindings -name "*.o" -exec cp {} $out/lib/ \; 2>/dev/null || true
          '';

          meta = with pkgs.lib; {
            description = "A sandboxed execution environment for unikernels";
            homepage = "https://github.com/Solo5/solo5";
            license = licenses.isc;
            platforms = platforms.linux;
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
            
            # Container tools
            docker
            
            # Solo5 unikernel environment
            solo5
          ];
          
          shellHook = ''
            echo "🦄 Unikernel environment with Solo5 ready!"
            echo ""
            echo "Available Solo5 tools:"
            ls -la ${solo5}/bin/solo5-* 2>/dev/null || echo "  Building Solo5..."
            echo ""
            echo "Try: solo5-spt --version"
          '';
        };
      });
}
