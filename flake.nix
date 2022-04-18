{
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, flake-utils }: flake-utils.lib.eachDefaultSystem (system: {
    packages =
      let
        inherit (nixpkgs.legacyPackages.${system}.writers) writeBashBin;
      in
      {
        homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
          inherit system;
          username = "keith"; # UPDATE
          homeDirectory = "/home/keith"; # UPDATE
          configuration = { pkgs, ... }: {
            home.packages = with pkgs; [ hello ];
          };
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
