{ ... }:
{
  programs = {
    helix = with builtins; {
      defaultEditor = true;
      enable = true;
      languages = fromTOML (readFile ./languages.toml);
      settings = fromTOML (readFile ./config.toml);
    };
  };
}
