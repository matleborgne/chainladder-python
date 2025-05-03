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
      });

      wrapPrefix = if (!pkgs.stdenv.isDarwin) then "LD_LIBRARY_PATH" else "DYLD_LIBRARY_PATH";

    in
    {
      packages = forAllSystems ({ pkgs, python, }: {

        default = pkgs.python312Packages.buildPythonPackage rec {        
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

          postBuild = ''
            wrapProgram "$out/bin/python3.12" --prefix ${wrapPrefix} : "${pythonldlibpath}"
          '';

        };        
      });

      
    };
}
