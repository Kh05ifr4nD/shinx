{ pkgs, ... }:
{
  home.packages = with pkgs; [
    flatter
    fplll
    tinymist
    (warp-terminal.override { waylandSupport = true; })
    zed-editor
  ];
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
