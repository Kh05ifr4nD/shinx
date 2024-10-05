{ ... }:
{
  programs = {
    helix = with builtins; {
      enable = true;
      languages = fromTOML (readFile ./languages.toml);
      settings = fromTOML (readFile ./config.toml);
    };
  };
}
