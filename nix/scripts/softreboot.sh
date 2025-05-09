#!/usr/bin/env sh

# This script performs a soft reboot using kexec.
# It loads the current kernel and initramfs into memory
# and then triggers a kexec reboot via systemd.

# Ensure the script is run as root
if [ "$UID" -ne 0 ]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Loading current kernel for kexec..."

# Find the current kernel version
CURRENT_KERNEL=$(uname -r)

KERNEL_IMAGE=$(find /boot -type f \
	-name "*${CURRENT_KERNEL}*" -o \
	-not -iname "*initrd*" \
	-not -iname "*initramfs*" \
	2>/dev/null | sort -V | tail -n 1)

INITRD_IMAGE=$(find /boot -type f \
	-name "*${CURRENT_KERNEL}*" -a \
	\( -iname "*initrd*" -o -iname "*initramfs*" \) \
	2>/dev/null | sort -V | tail -n 1)

# Check if kernel and initrd files exist
if [ ! -f "$KERNEL_IMAGE" ]; then
	echo "Error: Kernel image not found at $KERNEL_IMAGE"
	exit 1
fi
if [ ! -f "$INITRD_IMAGE" ]; then
	echo "Error: Initramfs image not found at $INITRD_IMAGE"
	exit 1
fi

# --- Get the current kernel command line ---
CURRENT_CMDLINE=$(cat /proc/cmdline)
echo "Using kernel command line: $CURRENT_CMDLINE"

# Load the kernel using kexec
# Explicitly append the current command line instead of --reuse-cmdline
sudo kexec -l "$KERNEL_IMAGE" --initrd="$INITRD_IMAGE" --append="$CURRENT_CMDLINE"

# Check if kexec loading was successful
if [ $? -ne 0 ]; then
	echo "Error: kexec loading failed."
	exit 1
fi

echo "kexec load successful. Initiating soft reboot..."

# Trigger the kexec reboot via systemd
sudo systemctl kexec

echo "kexec command sent. System should be rebooting shortly."

exit 0
