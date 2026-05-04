{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    lxgw-wenkai
    maple-mono.NF-CN-unhinted
    source-han-serif
  ];
}
