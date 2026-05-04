{
  nix = {
    gc = {
      automatic = true;
      interval = [
        {
          Hour = 3;
          Minute = 15;
          Weekday = 7;
        }
      ];
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      interval = [
        {
          Hour = 5;
          Minute = 15;
          Weekday = 7;
        }
      ];
    };

    settings = {
      connect-timeout = 8;
      download-attempts = 3;
      fallback = true;
      keep-derivations = true;
      keep-outputs = true;
      max-free = 68719476736;
      min-free = 34359738368;
    };
  };
}
