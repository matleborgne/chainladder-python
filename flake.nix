{
  description = "casact/chainladder-python";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:

    let
      allSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          python = pkgs.python3;
          pythonPackages = python.pkgs;
        in f { inherit pkgs python pythonPackages; }
      );

    in {
      packages = forAllSystems ({ pkgs, python, pythonPackages }: {
        default = pythonPackages.buildPythonPackage {
          pname = "chainladder";
          version = "0.8.24";
          src = ./.;

          format = "setuptools";

          pythonImportsCheck = [ "chainladder" ];

          nativeBuildInputs = with pythonPackages; [
            setuptools
          ];

          propagatedBuildInputs = with pythonPackages; [
            scikit-learn
            sparse
            pandas
            dill
            patsy
            packaging
          ];
        };
      });
    };
}
