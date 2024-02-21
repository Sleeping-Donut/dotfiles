# Dotfiles

## Nix stuff

Current goal: setting up config for LHC host

Done initial setup / install so can use `darwin-rebuild`

Problems with home-manager in some way with current setup

Current setup runs `darwin-rebuild switch --flake .#LHC` which should run `darwinConfigurations.LHC`

`darwinConfigurations` is defined in `nix/hosts/default.nix`.

In that file it loads the home manager module for darwin `homeManager.darwinModules.home-manager` as well as the config for the host

The config file for the host is at `nix/hosts/macOS/LHC/default.nix`

This config doesn't have much in it just for getting the minimum version running, but as soon as anything is configured for a user in the `home-manager` block there is an error when rebuilding

When the 2-3 lines that configure the `nathand` user in the `home-manager` block are removed it builds fine.

The error is:

```
building the system configuration...
error: builder for '/nix/store/71fp3hdgs01jc3z4bs8isxlnla8m9kmk-home-configuration-reference-manpage.drv' failed with exit code 2;
       last 6 log lines:
       > usage: nixos-render-docs
       >        [-h]
       >        [-j JOBS]
       >        {options,manual}
       >        ...
       > nixos-render-docs: error: unrecognized arguments: --header --footer /nix/store/zvy579ijwq795n5j1j5jiab9pxr9ahfa-options.json/share/doc/nixos/options.json /nix/store/k8a01vxppncx3w62fs5fb015r6ny97hz-home-configuration-reference-manpage/share/man/man5/home-configuration.nix.5
       For full logs, run 'nix log /nix/store/71fp3hdgs01jc3z4bs8isxlnla8m9kmk-home-configuration-reference-manpage.drv'.
error: 1 dependencies of derivation '/nix/store/v45rxiqiyxsfwyy6vdfdqwfn96ls4v4b-home-manager-applications.drv' failed to build
error: 1 dependencies of derivation '/nix/store/8vmhpzil0lp94p88j0lwzffrw7fjzwfb-home-manager-fonts.drv' failed to build
error: 1 dependencies of derivation '/nix/store/8j3x9j9myi03h0p21578rjz152hm266z-home-manager-path.drv' failed to build
error: 1 dependencies of derivation '/nix/store/40sg4lc0cjzp23hbfnqwzhzq9lwl7ax7-home-manager-generation.drv' failed to build
error: 1 dependencies of derivation '/nix/store/1via6dk5f7r7b57rz0x2mpp2bx8w90z3-user-environment.drv' failed to build
error: 1 dependencies of derivation '/nix/store/wckdag4q27i8nm5ydz9qdgifmdlsbnps-activation-nathand.drv' failed to build
error: 1 dependencies of derivation '/nix/store/jl9k4svq59z5prhbxac3f33mh5k0sldd-darwin-system-23.05.20240103.70bdade+darwin4.0e6857f.drv' failed to build
```
