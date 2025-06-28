# TODO

## Power state

On linux use `upower`
`-e` flag to list power sources
`-i PATH_TO_SOURCE` to show info on power source

## Systemd logind behaviour

Have systemd configs like logind behaviour somewhere
in `/etc/systemd/system/logind.conf`
```
[Login]
HandlePowerKey=suspend
HandlePowerKeyLongPress=poweroff
```

## Nix stuff

Go change the relevant modules that have home.file.".config/NAME" to use the `xdg.configFile."NAME"`
It has same target source thing but is more appropriate and target is within xdg_config

use external store
```nix
home.file.".config/nvim" = {
  source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
  recursive = true;
};
```
symlink pointing to the source (in the case of LHC ~/dotfiles/config/nvim) that needs the full path of a flake
recursive means as long as dir structure changes no rebuild needed. Contents can change as you like (great for updating lazy)

