{
  description = "Shell Switcher (Hyprland + Stylix + Rofi)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      f (import nixpkgs { inherit system; })
    );
    in {
      packages = forAllSystems (pkgs: {
        shellswitcher = import ./modules/scripts/shellswitcher.nix { inherit pkgs; config = {}; };
        default = self.packages.${pkgs.system}.shellswitcher;
      });

      homeManagerModules.default = { pkgs, config, ... }: {
        home.packages = [ (import ./modules/scripts/shellswitcher.nix { inherit pkgs config; }) ];
        home.file.".config/rofi/shellswitcher.rasi".source = ./modules/rofi/shellswitcher.rasi;
        home.file.".config/rofi/themes/shellswitcher.rasi".source = ./modules/rofi/themes/shellswitcher.rasi;
      };
    };
}
