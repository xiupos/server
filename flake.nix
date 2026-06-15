{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    colmena.url = "github:zhaofengli/colmena";
    arion = { url = "github:hercules-ci/arion"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { nixpkgs, colmena, arion, sops-nix, ... }: {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs { system = "x86_64-linux"; };
        specialArgs = { inherit arion sops-nix; };
      };

      defaults = { sops-nix, ... }: {
        imports = [
          sops-nix.nixosModules.sops
          ./modules/common.nix
          ./modules/lxc.nix
        ];
      };

      chatai = { ... }: {
        deployment.targetHost = "chatai";
        imports = [ ./hosts/chatai.nix ];
      };

      misskey-test = { ... }: {
        deployment.targetHost = "misskey-test";
        imports = [ ./hosts/misskey-test.nix ];
      };

      misskey-main = { ... }: {
        deployment.targetHost = "misskey-main";
        imports = [ ./hosts/misskey-main.nix ];
      };

      monitor = { ... }: {
        deployment.targetHost = "monitor";
        imports = [ ./hosts/monitor.nix ];
      };
    };
  };
}
