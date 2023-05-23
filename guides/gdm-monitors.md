# GNOME Display Manager - Monitor Setup

[ref](https://discussion.fedoraproject.org/t/gnome-login-menu-on-wrong-screen/74154/2)

If display position wrong / unconfigured use config from gnome config:

```sh
sudo cp -f ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo chown $(id -u gdm):$(id -g gdm) ~gdm/.config/monitors.xml
sudo restorecon ~gdm/.config/monitors.xml
```

