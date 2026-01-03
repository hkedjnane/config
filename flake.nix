{
  description = "System + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      variables = import ./variables.nix { inherit pkgs; lib = pkgs.lib; };
      machines = import ./machines;
    in
    {
      nixosConfigurations = builtins.mapAttrs (machineName: machine: nixpkgs.lib.nixosSystem {
              modules = [
                machine.config
                variables
                ./system/configuration.nix
              ];
            }) machines;
      homeConfigurations =
        builtins.foldl' (
          acc: machineName: acc // (
        let
          machine = machines.${machineName};
        in
        builtins.foldl' (
          acc2: userName: acc2 // {
            "${machineName}-${userName}" =
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              variables
              machine.config.userList.${userName}.userConfig
              ./home/home.nix
            ];
          };
          }
        ) {} (builtins.attrNames machine.config.userList)
          )
        ) {} (builtins.attrNames machines);
    };
}
