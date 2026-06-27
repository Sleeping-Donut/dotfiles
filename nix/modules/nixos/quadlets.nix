{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.quadlets;
in {
  options.quadlets = mkOption {
    description = "Use quadlets with nix-built OCI images";
    default = {};
    type = types.attrsOf (types.submodule ({ name, ... }: {
      # This allows any arbitrary [Section] and Key = Value pairs
      freeformType = with types; attrsOf (attrsOf anything);
    }));
  };

  config = mkIf (cfg != {}) {
    # 1. Dynamically generate the .container files
    xdg.configFile = concatMapAttrs (name: qCfg:
      let
        # Isolate the Container block (default to empty if they omitted it)
        rawContainer = qCfg.Container or {};

        # Check if they supplied a Nix derivation package as the image
        hasDrvImage = rawContainer ? Image && isDerivation rawContainer.Image;

        processedImage = if hasDrvImage then
          let
            imgName = rawContainer.Image.imageName or rawContainer.Image.name;
            imgTag = rawContainer.Image.imageTag or "latest";
          in "${imgName}:${imgTag}"
        else
          rawContainer.Image or null;

        # Inject ContainerName automatically, but let them override it if they want.
        # If the image was a derivation, swap it out for its evaluated string name.
        fixedContainer = { ContainerName = name; }
          // rawContainer
          // (optionalAttrs hasDrvImage { Image = processedImage; });

        # Merge the modified Container block back into the freeform configuration
        finalIniStructure = qCfg // { Container = fixedContainer; };
      in {
        "containers/systemd/${name}.container".text = generators.toINI {} finalIniStructure;
      }
    ) cfg;

    # 2. Automatically generate the image loading services for Nix derivations
    systemd.user.services = concatMapAttrs (name: qCfg:
      let
        rawContainer = qCfg.Container or {};
        hasDrvImage = rawContainer ? Image && isDerivation rawContainer.Image;
      in
      if hasDrvImage then {
        "load-${name}-image" = {
          Unit = {
            Description = "Load Nix-built image for ${name} into Podman";
            Before = [ "${name}.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${getExe pkgs.podman}/bin/podman load -i ${rawContainer.Image}";
            RemainAfterExit = true;
          };
          Install = { WantedBy = [ "default.target" ]; };
        };
      } else {}
    ) cfg;
  };
}

