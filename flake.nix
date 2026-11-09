{
  description = "System + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland 0.57 only reads hyprland.lua and ignores hyprland.conf. Take
    # Hyprland (and hyprtasking) from the previous lock, which ships 0.56.2, until
    # the config is migrated to Lua.
    nixpkgs-hyprland.url = "github:NixOS/nixpkgs/494ce7fd23ff6a5dff39e1fb11e9b6f2ac74bf25";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-hyprland, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      pkgs-hyprland = import nixpkgs-hyprland {
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
            extraSpecialArgs = { inherit pkgs-hyprland; };
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
