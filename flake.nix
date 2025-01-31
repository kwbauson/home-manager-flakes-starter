{
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, flake-utils }: flake-utils.lib.eachDefaultSystem (system: {
    packages =
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          username = "keith"; # UPDATE
          homeDirectory = "/home/keith"; # UPDATE
          configuration = { pkgs, ... }: {
            home.packages = with pkgs; [ hello ];
          };
        };

        hm = writers.writeBashBin "hm" ''
          ${home-manager.packages.${system}.home-manager}/bin/home-manager \
            --flake ${self}#default \
            "$@"
        '';
        build = writers.writeBashBin "build" "nix run ${self}#hm build";
        switch = writers.writeBashBin "switch" "nix run ${self}#hm switch";
      };
  });
}
