{ pkgs, ... }:
{
  programs = {
    sagemath = {
      enable = true;
      package = pkgs.sage.override {
        extraPythonPackages =
          ps: with ps; [
            pycryptodome
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