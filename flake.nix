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
      packages = forAllSystems ({ pkgs, python, system }: {

        default = pkgs.python312Packages.buildPythonPackage rec {        
          name = "chainladder";
          src = self;

          format = "setuptools";
          pythonImportsCheck = [ "chainladder" ];

          nativeBuildInputs = with pkgs; [
            python3Packages.setuptools

            python3Packages.scikit-learn
            python3Packages.sparse
            python3Packages.pandas
            python3Packages.dill
            python3Packages.patsy
            python3Packages.packaging
          ];
        };        
      });

      overlays.default = final: prev: {
        python312Packages = prev.python312.Packages // {
          chainladder = self.packages.${prev.system}.default {};
        };
      };
      
    };
}
