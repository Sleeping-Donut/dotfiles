{ config, lib, ... }:

with lib;

let
  cfg = config.quadlets0;
in {
  options.quadlets0 = mkOption {
    description = "Rootful quadlets with nix-built OCI images";
    default = {};
    type = types.attrsOf (types.submodule ({ name, ... }: {
      freeformType = types.attrsOf (types.attrsOf types.anything);
    }));
  };

  config = mkIf (cfg != {}) {
    assertions = [{
      assertion = config.virtualisation.podman.enable;
      message = ''
        quadlets0 requires virtualisation.podman.enable = true.
        Add `virtualisation.podman.enable = true;` to your NixOS configuration.
      '';
    }];

    environment.etc = concatMapAttrs (name: qCfg:
      let
        rawContainer = qCfg.Container or {};
        hasDrvImage = rawContainer ? Image && isDerivation rawContainer.Image;

        processedImage = if hasDrvImage then
          "docker-archive:${rawContainer.Image}"
        else
          rawContainer.Image or null;

        fixedContainer = { ContainerName = name; }
          // rawContainer
          // (optionalAttrs hasDrvImage { Image = processedImage; });

        finalIniStructure = qCfg // { Container = fixedContainer; };
      in {
        "containers/systemd/${name}.container".text = generators.toINI {
          listsAsDuplicateKeys = true;
        } finalIniStructure;
      }
    ) cfg;
  };
}
