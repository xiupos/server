colmena := "nix run --accept-flake-config github:nix-community/colmena --"

check:
  nix flake check

deploy:
  {{colmena}} apply --parallel 1

deploy-on hostname:
  {{colmena}} apply --on {{hostname}} --parallel 1

build:
  {{colmena}} build --parallel 1

build-on hostname:
  {{colmena}} build --on {{hostname}} --parallel 1

update:
  nix flake update

update-keys:
  sops updatekeys secrets/*.yaml
