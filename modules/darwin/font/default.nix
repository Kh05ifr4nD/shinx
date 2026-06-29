{ pkgs, ... }:
let
  simsun = pkgs.runCommandLocal "simsun-font" { } ''
    install -Dm644 ${./simsun.ttc} $out/share/fonts/truetype/simsun.ttc
  '';
in
{
  fonts.packages = with pkgs; [
    lxgw-wenkai
    maple-mono.NF-CN-unhinted
    simsun
    source-han-serif
  ];
}
