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
          (import ./services/misskey-mk {
            name = "misskey-mk-dev";
            url = "https://mk-dev.xiupos.net/";
            imageTag = "2026.5.4";
            extraConfig = "proxy: http://127.0.0.1:3128";
          })
          (import ./services/misskey-mk/backup.nix {
            name = "misskey-mk-dev";
            secretsPath = ./secrets;
          })
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
          (import ./services/misskey-mk {
            name = "misskey-mk-main";
            url = "https://mk.xiupos.net/";
            imageTag = "2026.5.4";
          })
          (import ./services/misskey-mk/backup.nix {
            name = "misskey-mk-main";
            secretsPath = ./secrets;
          })
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
