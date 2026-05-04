{
  fetchzip,
  lib,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mac-brightnessctl";
  version = "0.2.1";

  src = fetchzip {
    url = "https://github.com/rakalex/mac-brightnessctl/archive/refs/tags/${finalAttrs.version}.tar.gz";
    hash = "sha256-ynlZhYaWA09ZIUIAw2UDMIOMyIMe6K59k+xq7q2gvaI=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 mac-brightnessctl $out/bin/mac-brightnessctl
    runHook postInstall
  '';

  meta = {
    description = "CLI tool for controlling keyboard backlight brightness on macOS";
    homepage = "https://github.com/rakalex/mac-brightnessctl";
    license = lib.licenses.mit;
    mainProgram = "mac-brightnessctl";
    platforms = lib.platforms.darwin;
  };
})
