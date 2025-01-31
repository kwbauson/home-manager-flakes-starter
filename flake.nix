{
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, flake-utils }: flake-utils.lib.eachDefaultSystem (system: {
    packages =
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.writers) writeBashBin;
        hmModule = { config, pkgs, ... }: {
          home.username = "keith"; # UPDATE
          home.homeDirectory = "/home/${config.home.username}"; # UPDATE if home directory different from username
          home.stateVersion = "24.11"; # UPDATE to the latest by searching for "stateVersion" in the docs https://nix-community.github.io/home-manager/
          home.packages = with pkgs; [ hello ];
        };
      in
      {
        homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ hmModule ];
        };

        hm = writeBashBin "hm" ''
          ${home-manager.packages.${system}.home-manager}/bin/home-manager \
            --flake ${self}#default \
            "$@"
        '';
        build = writeBashBin "build" "nix run ${self}#hm build";
        switch = writeBashBin "switch" "nix run ${self}#hm switch";
      };
  });
}
