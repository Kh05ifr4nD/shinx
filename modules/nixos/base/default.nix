{
  arch,
  flake,
  host,
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
  networking.hostName = host;
  nixpkgs.hostPlatform = arch;
  programs.nix-ld = {
    dev.enable = true;
    libraries = with pkgs; [
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      bzip2
      cairo
      cups
      curlWithGnuTls
      dbus
      dbus-glib
      desktop-file-utils
      e2fsprogs
      expat
      flac
      fontconfig
      freeglut
      freetype
      fribidi
      fuse
      fuse3
      gdk-pixbuf
      glew110
      glib
      gmp
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-ugly
      gst_all_1.gstreamer
      gtk2
      harfbuzz
      icu
      keyutils.lib
      libappindicator-gtk2
      libcaca
      libcanberra
      libcap
      libclang.lib
      libdbusmenu
      libdrm
      libgcrypt
      libGL
      libGLU
      libgpg-error
      libidn
      libjack2
      libjpeg
      libmikmod
      libogg
      libpng12
      libpulseaudio
      librsvg
      libsamplerate
      libthai
      libtheora
      libtiff
      libudev0-shim
      libusb1
      libuuid
      libvdpau
      libvorbis
      libvpx
      libxcrypt-legacy
      libxkbcommon
      libxml2
      mesa
      nspr
      nss
      openssl
      p11-kit
      pango
      pixman
      python3
      SDL
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_ttf
      SDL_image
      SDL_mixer
      SDL_ttf
      speex
      tbb
      udev
      vulkan-loader
      wayland
      xorg.libICE
      xorg.libpciaccess
      xorg.libSM
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXft
      xorg.libXi
      xorg.libXinerama
      xorg.libXmu
      xorg.libXrandr
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXt
      xorg.libXtst
      xorg.libXxf86vm
      xorg.xcbutil
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
      xorg.xkeyboardconfig
      xz
      zlib
    ];
  };
  services.openssh.enable = true;
  system.stateVersion = "24.05";
}
