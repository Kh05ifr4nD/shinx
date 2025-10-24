{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with self.nixosModules; [
      audio
      base
      bluetooth
      fcitx5
      gui
      hardware
      kmscon
      kde
      network
      nvidia
    ]);
  # Home imports（按主机声明，使用 self.homeModules 与 NixOS 类似的 with 语法）
  modules.home.imports = with self.homeModules; [
    gui
    apps.browser
    apps.media
    apps.office
    apps.obs
    apps.research
  ];
  _module.args = {
    arch = "x86_64-linux";
    host = baseNameOf ./.;
  };
}
