{ ... }:
{
  programs = {
    atuin = {
      enable = true;
      enableNushellIntegration = true;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      configFile.source = ./nushell/config.nu;
      enable = true;
      envFile.source = ./nushell/env.nu;
      loginFile.source = ./nushell/login.nu;
      shellAliases = {
        cd = "z";
        docker = "podman";
        ls = "ls -afm";
      };
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = with builtins; fromTOML (readFile ./starship.toml);
    };
  };
}