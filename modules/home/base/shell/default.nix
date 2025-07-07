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
        j = "just";
        ls = "ls -afm";
        shinx = "sudo nix run /home/meandssh/shinx#activate";
      };
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = fromTOML (builtins.readFile ./starship.toml);
    };
  };
}
