# A module that automatically imports everything else in the parent folder.
{
  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));
}
