#!/bin/bash

# Define the tasks in functions
setup_partitions() {
    echo "Setting up partitions..."
    mkfs.fat -F32 /dev/nvme0n1p1
    mkswap /dev/nvme0n1p2
    swapon /dev/nvme0n1p2
    mkfs.ext4 /dev/nvme0n1p3
    mount /dev/nvme0n1p3 /mnt
}

mount_boot_partition() {
    echo "Mounting boot partition..."
    mkdir /mnt/boot
    mount /dev/nvme0n1p1 /mnt/boot
}

install_base_system() {
    echo "Installing base system..."
    pacstrap /mnt base base-devel linux linux-firmware amd-ucode neovim git dhcpcd iwd zsh postgresql nvidia nvidia-utils nvidia-settings pipewire pipewire-alsa pipewire-pulse pipewire-jack i3-wm python python-pip sudo rustup rxvt-unicode grub efibootmgr sudo python i3 xorg-server xorg-xinit xorg-xprop git make fakeroot rxvt-unicode pipewire wireplumber polkit ffmpeg
}

generate_fstab() {
    echo "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
}

chroot_system() {
    echo "Chrooting into new system..."
    arch-chroot /mnt 
}

# Define task names and corresponding functions in an associative array
declare -A tasks
tasks=(
    ["setup_partitions"]=setup_partitions
    ["mount_boot_partition"]=mount_boot_partition
    ["install_base_system"]=install_base_system
    ["generate_fstab"]=generate_fstab
    ["chroot_system"]=chroot_system
)

# Catch errors
trap 'echo "Script failed on task: $current_task"' ERR

# Execution of tasks
start_task=${1:-${!tasks[@]:0:1}}
for current_task in "${!tasks[@]}"; do
    if [[ "$current_task" == "$start_task" || -n "$execute" ]]; then
        ${tasks[$current_task]}
        execute=true
    fi
done
