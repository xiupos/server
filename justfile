deploy hostname:
  nix run nixpkgs#nixos-rebuild -- switch --flake '.#{{hostname}}' --target-host root@{{hostname}}
