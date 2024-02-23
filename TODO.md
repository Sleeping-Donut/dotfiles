# TODO

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

