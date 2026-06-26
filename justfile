colmena := "nix run --accept-flake-config github:nix-community/colmena --"

check:
  nix flake check

deploy:
  {{colmena}} apply

deploy-on hostname:
  {{colmena}} apply --on {{hostname}}

build:
  {{colmena}} build

build-on hostname:
  {{colmena}} build --on {{hostname}}

update:
  nix flake update

update-keys:
  sops updatekeys secrets/*.yaml
