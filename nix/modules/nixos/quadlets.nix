{ config, pkgs, lib, ... }:

let
  cfg = config.quadlets;

  collectDeps = qCfg:
    qCfg.dependsOn
    ++ lib.optional (qCfg.shareNetworkWith or null != null) qCfg.shareNetworkWith;

  appendToList = existing: newItems:
    let
      parts = lib.filter (s: s != "") [ (lib.toString existing) (lib.concatStringsSep " " newItems) ];
    in lib.concatStringsSep " " parts;
in {
  options.quadlets = lib.mkOption {
    description = "Use quadlets with nix-built OCI images";
    default = {};
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      options = {
        dependsOn = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Other quadlet containers this one depends on. Injects Requires= and After= into the [Unit] section.";
          example = [ "service-a" "service-b" ];
        };
        shareNetworkWith = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Share the network namespace of another quadlet container. Injects Network= into [Container] and an implicit service dependency.";
          example = "mullvad";
        };
      };
      freeformType = with lib.types; attrsOf (attrsOf lib.types.anything);
    }));
  };

  config = lib.mkIf (cfg != {}) {
    xdg.configFile = lib.concatMapAttrs (name: qCfg:
      let
        deps = collectDeps qCfg;

        rawContainer = qCfg.Container or {};
        rawUnit = qCfg.Unit or {};

        hasDrvImage = rawContainer ? Image && lib.isDerivation rawContainer.Image;

        processedImage = if hasDrvImage then
          let
            imgName = rawContainer.Image.imageName or rawContainer.Image.name;
            imgTag = rawContainer.Image.imageTag or "latest";
          in "${imgName}:${imgTag}"
        else
          rawContainer.Image or null;

        fixedContainer = { ContainerName = name; }
          // rawContainer
          // (lib.optionalAttrs hasDrvImage { Image = processedImage; })
          // (lib.optionalAttrs (qCfg.shareNetworkWith or null != null) {
              Network = "${qCfg.shareNetworkWith}.container";
            });

        fixedUnit = if deps == [] then rawUnit
          else rawUnit // {
            Requires = appendToList (rawUnit.Requires or null) (map (d: "${d}.service") deps);
            After = appendToList (rawUnit.After or null) (map (d: "${d}.service") deps);
          };

        cleaned = lib.removeAttrs qCfg [ "dependsOn" "shareNetworkWith" ];
        finalIniStructure = cleaned
          // { Unit = fixedUnit; }
          // { Container = fixedContainer; };
      in {
        "containers/systemd/${name}.container".text = lib.generators.toINI {} finalIniStructure;
      }
    ) cfg;

    systemd.user.services = lib.concatMapAttrs (name: qCfg:
      let
        rawContainer = qCfg.Container or {};
        hasDrvImage = rawContainer ? Image && lib.isDerivation rawContainer.Image;
      in
      if hasDrvImage then {
        "load-${name}-image" = {
          Unit = {
            Description = "Load Nix-built image for ${name} into Podman";
            Before = [ "${name}.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.podman}/bin/podman load -i ${rawContainer.Image}";
            RemainAfterExit = true;
          };
          Install = { WantedBy = [ "default.target" ]; };
        };
      } else {}
    ) cfg;
  };
}

