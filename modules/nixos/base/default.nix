{
  arch,
  flake,
  hst,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
in
{
  environment = {
    sessionVariables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      bat
      curl
      git
      helix
      nushell
      ripgrep
      kdePackages.breeze
      kdePackages.qtwayland
      qt6ct
      unzip
      wget
      xz
      yazi
    ];
  };
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with inputs; [
      nix-ld.nixosModules.nix-ld
      sops-nix.nixosModules.sops
    ]);
  networking.hostName = hst;
  nixpkgs.hostPlatform = arch;
  programs.nix-ld.dev.enable = true;
  services.openssh.enable = true;
  system.stateVersion = "24.05";
}
