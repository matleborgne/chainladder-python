{
  description = "casact/chainladder-python";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f  {
        pkgs = import nixpkgs { inherit system; };
        python = with import nixpkgs { inherit system; }; python3.withPackages (ps: with ps; [ ]);
      });

    in
    {
      packages = forAllSystems ({ pkgs, python }: {

        default = pkgs.python3Packages.buildPythonPackage rec {        
          name = "chainladder";
          src = self;

          nativeBuildInputs = with pkgs; [
            desktop-file-utils
            appstream-glib
            pkg-config
            python3
            wrapGAppsHook4
          ];

          buildInputs = with pkgs; [
            haskellPackages.gi-gdk
            haskellPackages.gi-gtk
          ];

#          preFixup = ''
#            wrapProgram $out/bin/video-downloader \
#              --prefix PYTHONPATH : ${python}/${python.sitePackages} \
#          '';

        };
      });
    };
}
