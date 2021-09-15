{ pkgs
}:
with pkgs;
mkYarnPackage {
  name = "cml";
  src = fetchFromGitHub {
    owner = "iterative";
    repo = "cml";
    rev = "4f7a5d95fb75f9dbf052bc9789ca235716560710";
    sha256 = "1bcjbcrjs2zmfvfz7iskhs9b5dxxszbah6hg3a4qjd3ic6y13sxn";
  };
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
}
