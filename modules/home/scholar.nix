{ pkgs, ... }:
{
  home.packages = with pkgs; [
    flatter
    fplll
    tinymist
  ];
  programs = {
    sagemath = {
      enable = true;
      package = pkgs.sage.override {
        extraPythonPackages =
          ps: with ps; [
            loguru
            pycryptodome
            pyside6
          ];
        requireSageTests = false;
      };
    };
    texlive = {
      enable = true;
      extraPackages = tpkgs: {
        inherit (tpkgs)
          scheme-full
          ;
      };
    };
  };
}
