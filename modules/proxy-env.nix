{ lib }:

let
  proxy = "http://127.0.0.1:20122";
  lowercase = {
    all_proxy = proxy;
    http_proxy = proxy;
    https_proxy = proxy;
    no_proxy = "localhost,127.0.0.1,::1,*.local,100.64.0.0/10";
  };
in
lowercase // lib.mapAttrs' (name: value: lib.nameValuePair (lib.toUpper name) value) lowercase
