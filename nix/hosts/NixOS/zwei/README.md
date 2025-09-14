# Zwei info

## Install

> [!CAUTION]
> Disable rclone backups in config before installing
> If it boots on a fresh install and tries a backup it might overwrite the remote backup which is recoverable but annoying
> Re-enable them after restoring the backup

### Partition

> [!IMPORTANT]
> Instructions assume drive to install to is `/dev/sdb`, which is obviously is not a given but its good enough for reminder instructions.

To make the partition, easiest way is using the script flag.
Should be using gpt not mbr
`set 1 esp on` is to make that partition an EFI system partition
Boot partition should be min ~1GiB to avoid full boot partition annoyances
If more RAM maybe larger swap but its fine

```sh
sudo parted --script /dev/sdb \
    mklabel gpt mkpart NIXBOOT fat32 1MiB 1GiB set 1 esp on \
    mkpart NIXSWAP linux-swap 1GiB 17GiB \
    mkpart NIXROOT btrfs 17GiB 100%
```

### Filesytem

```sh
sudo mkfs.fat -F 32 -n NIXBOOT /dev/sdb1
sudo mkswap -L NIXSWAP /dev/sdb2
sudo mkfs.btrfs -L NIXROOT /dev/sdb3
```

## Btrfs Subvolumes

```sh
sudo mkdir /mnt/btrfs
sudo mount /dev/sdb3 /mnt/btrfs
sudo btrfs subvolume create /mnt/btfrs/@
sudo btrfs subvolume create /mnt/btfrs/@home
sudo btrfs subvolume create /mnt/btfrs/@opt
sudo btrfs subvolume create /mnt/btfrs/@var_lib
sudo umount /mnt/btrfs
sudo rmdir /mnt/btrfs
```

## Mount for install

```sh
sudo mkdir /mnt
sudo mount -o compress=zstd,subvol=@ /dev/sdb3 /mnt
sudo mkdir -p /mnt/{boot,home,opt,var/lib}
sudo mount -o compress=zstd,subvol=@home /dev/sdb3 /mnt/home
sudo mount -o compress=zstd,subvol=@opt /dev/sdb3 /mnt/opt
sudo mount -o compress=zstd,subvol=@var_lib /dev/sdb3 /mnt/var/lib
sudo mount /dev/sdb1 /mnt/boot
```

Probably a good idea to use the swap partition that was just created so:

```sh
sudo swapon /dev/sdb2
```

## Install

> [!TIP]
> Can install straight from a remote repo like github or can clone first and source from the local copy.
>
> When running from a remote repo, I don't know how to force `nixos-install` to pull the latest commit down again
> Can do hacky things like adding `github:<USER>/<REPO>/<BRANCH>` or instead of branch the hash of the most recent commit, as these are different urls for the flake which is enough to cause a cache miss on fetching the flake.
> To make it easier to pull latest or grab any version of the repo as needed, just clone locally for normal git pulling.

> [!IMPORTANT]
> Check that the plex package file is available from the plex download servers **before** running `nixos-install`

The root password is not set in the config so, after the installer finishes, it will prompt you to set the root password

```sh
sudo nixos-install --root /mnt --flake 'github:Sleeping-Donut/dotfiles#zwei'
```

> [!NOTE]
> The user password is not set during the install as it is not in the nix config
> Use `nixos-enter` to chroot into the environment so the user password can be set
>
> ```sh
> sudo nixos-enter
> : Should be in the installed nixos environment now
> passwd nathand
> exit
> ```

## Reboot into install

```sh
sudo reboot
```

Might need to change UEFI boot sequence too

