{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, arion, sops-nix, ... }: {
    nixosConfigurations = {
      chatai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          arion.nixosModules.arion
          ./modules/common.nix
          ./modules/lxc.nix
          ./modules/docker.nix
          ./hosts/chatai/configuration.nix

          # Open WebUI
          ./services/open-webui

          # Grafana Alloy
          ./services/grafana-alloy
          ./services/grafana-alloy/docker.nix
        ];
      };

      misskey-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          arion.nixosModules.arion
          ./modules/common.nix
          ./modules/lxc.nix
          ./modules/docker.nix
          ./hosts/misskey-test/configuration.nix

          # Misskey
          ./services/misskey-mk-dev
          ./services/misskey-mk-dev/backup.nix
          ./services/cloudflare-tunnel

          # Grafana Alloy
          ./services/grafana-alloy
          ./services/grafana-alloy/docker.nix
          ./services/grafana-alloy/postgres.nix
        ];
      };

      misskey-main = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          arion.nixosModules.arion
          ./modules/common.nix
          ./modules/lxc.nix
          ./modules/docker.nix
          ./hosts/misskey-main/configuration.nix

          # Misskey
          ./services/misskey-mk-main
          ./services/misskey-mk-main/backup.nix
          ./services/cloudflare-tunnel

          # Grafana Alloy
          ./services/grafana-alloy
          ./services/grafana-alloy/docker.nix
          ./services/grafana-alloy/postgres.nix
        ];
      };

      monitor = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./modules/common.nix
          ./modules/lxc.nix
          ./hosts/monitor/configuration.nix
          ./services/grafana-alloy

          # Grafana Stack
          ./services/grafana-stack

          # Grafana Alloy
          ./services/grafana-alloy
          ./services/grafana-alloy/rsyslog.nix
        ];
      };
    };
  };
}
