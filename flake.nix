{
  description = "Ambxst by Axenide";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixgl, ... }: let
    linuxSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
    ];

    forAllSystems = f:
      builtins.foldl' (acc: system: acc // { ${system} = f system; }) {} linuxSystems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      lib = nixpkgs.lib;
      isNixOS = pkgs ? config && pkgs.config ? nixosConfig;
      nixGL = nixgl.packages.${system}.nixGLDefault;

      wrapWithNixGL = pkg:
        if isNixOS then pkg else pkgs.symlinkJoin {
          name = "${pkg.pname or pkg.name}-nixGL";
          paths = [ pkg ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            for bin in $out/bin/*; do
              if [ -x "$bin" ]; then
                mv "$bin" "$bin.orig"
                makeWrapper ${nixGL}/bin/nixGL "$bin" --add-flags "$bin.orig"
              fi
            done
          '';
        };

      baseEnv = with pkgs; [
        (wrapWithNixGL quickshell)
        (wrapWithNixGL gpu-screen-recorder)
        (wrapWithNixGL mpvpaper)

        brightnessctl
        ddcutil
        wl-clipboard
        cliphist
      ] ++ (if isNixOS then [ power-profiles-daemon ] else [ nixGL ]) ++ (with pkgs; [
        mesa
        libglvnd
        egl-wayland
        wayland

        qt6.qtbase
        qt6.qtsvg
        qt6.qttools
        qt6.qtwayland
        qt6.qtdeclarative
        qt6.qtimageformats

        kdePackages.breeze-icons
        hicolor-icon-theme
        fuzzel
        wtype
        imagemagick
        matugen
        ffmpeg
        playerctl

        pipewire
        wireplumber
      ]);

      envAmbxst = pkgs.buildEnv {
        name = "Ambxst-env";
        paths = baseEnv;
      };

      launcher = pkgs.writeShellScriptBin "ambxst" ''
        exec ${lib.optionalString (!isNixOS) "${nixGL}/bin/nixGL "}${pkgs.quickshell}/bin/qs -p ${self}/shell.qml
      '';

      Ambxst = pkgs.buildEnv {
        name = "Ambxst";
        paths = [ envAmbxst launcher ];
      };
    in {
      default = Ambxst;
      Ambxst = Ambxst;
    });
  };
}
