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
      connect-timeout = 4;
      download-attempts = 4;
      fallback = true;
      keep-derivations = true;
      keep-outputs = true;
      max-free = 68719476736;
      min-free = 34359738368;
      stalled-download-timeout = 4;
    };
  };
}
