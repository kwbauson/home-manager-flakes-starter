{
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, flake-utils }: flake-utils.lib.eachDefaultSystem (system: {
    packages =
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.writers) writeBashBin;
      in
      {
        homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ({ pkgs, ... }: {
            home.username = "keith"; # UPDATE
            home.homeDirectory = "/home/keith"; # UPDATE
            home.packages = with pkgs; [ hello ];
          }) ];
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
