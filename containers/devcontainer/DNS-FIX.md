# macOS 26 Container Build DNS Fix

## Problem

During `container build`, the buildkit container may fail to resolve DNS names, preventing `nix` and other package managers from working during image builds.

## Root Cause

When `container system stop`/`start` cycles happen, the default network subnet can change (e.g., `192.168.64.0/24` → `192.168.65.0/24`). The existing buildkit builder container retains the old gateway IP as its DNS server, which becomes unreachable after the subnet change.

## Fix

Delete the buildkit container to force recreation with the correct DNS:

```bash
container builder delete --force
container system stop
container system start
```

### Alternative Workaround

If the above doesn't help, manually patch DNS in the running builder:

```bash
container exec buildkit /bin/sh -c 'echo "nameserver 1.1.1.1" > /etc/resolv.conf'
```

Then run your build.

## Reference

- GitHub Issue: [#656](https://github.com/apple/container/issues/656)
- Related PR: [#1370](https://github.com/apple/container/pull/1370)
