{
  description = "casact/chainladder-python";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
      
  };

  outputs = { self, nixpkgs, }@inputs:

    let
      allSystems = [
        "x86_64-linux"
        #"aarch64-linux"
        #"x86_64-darwin"
        #"aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f  {
        pkgs = import nixpkgs { inherit system; };
        python = with import nixpkgs { inherit system; }; python3.withPackages (ps: with ps; [ scikit-learn ]);
      });

    in
    {
      packages = forAllSystems ({ pkgs, python, }: {

        default = pkgs.python3Packages.buildPythonPackage rec {        
          name = "chainladder";
          src = self;

          format = "setuptools";
          pythonImportsCheck = [ "chainladder" ];

          nativeBuildInputs = with pkgs.python3Packages; [
            setuptools
            scikit-learn
            sparse
            pandas
            dill
            patsy
            packaging
          ];
        };        
      });

      overlays.default = final: prev: {
        python3Packages = prev.python3Packages // {
          chainladder = self.packages.x86_64-linux.default;
        };
      };
      
    };
}
