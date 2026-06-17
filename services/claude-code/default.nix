{ config, pkgs, lib, claude-code, ... }: {
  nixpkgs.overlays = [ claude-code.overlays.default ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
  environment.systemPackages = [ pkgs.claude-code ];

  nix.settings = {
    substituters = [ "https://claude-code.cachix.org" ];
    trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };
}
