#!/bin/sh

set -e


###### Nix System Install ######

# This script installs our NixOS and Home Manager configuration on the current machine.
# We can skip the NixOS system install if the machine is not running NixOS.
# Currently, this basically just creates symlinks.

# NixOS system install
nixos_system_install() {

    # Check if symlink already exists
    [ -L /etc/nixos ] && { echo "NixOS system configuration already installed."; return; }


    # We check for the /etc/NIXOS file to detect if the machine is running NixOS.
    grep 'NAME=NixOS' /etc/os-release >/dev/null || { echo "Machine is not running NixOS."; return; }

    # Ask if user wants to install the NixOS system configuration
    echo "Do you want to install the NixOS system configuration? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Skipping NixOS system install."
        return 0
    fi

    echo "Installing NixOS system configuration..."

    echo "Installing NixOS system configuration requires sudo permissions."
    echo "Do you want to continue? (y/n)"
    read -r response
    [ "$response" = "y" ]  || { echo "Skipping NixOS system install."; return 0; }
    sudo echo "Sudo permissions granted." || { echo "Sudo permissions required to continue."; return 0; }

    # We start by copying the hardware-configuration.nix file to our nixconfig folder
    cp /etc/nixos/hardware-configuration.nix $(pwd)/nixconfig/hardware-configuration.nix

    # We're going to backup the current /etc/nixos folder
    sudo cp -r /etc/nixos/ /etc/.nixos.bak

    # Delete the folder
    sudo rm /etc/nixos -rf

    # We symlink our nixconfig folder to the /etc/nixos folder
    sudo ln -sf $(pwd)/nixconfig /etc/nixos

    # Now we run the NixOS system install
    sudo nixos-rebuild switch || { echo "NixOS system configuration failed."; return 1; }
    echo "NixOS system configuration installed successfully, may require a reboot."
    echo "To update the system configuration, run 'sudo nixos-rebuild switch'."
}

# Installs nix if user chooses to use home-manager
nix_install() {
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) || { echo "Nix installation failed."; return 1; }
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    echo "Nix installed successfully."
}

# Home Manager install
home_manager_install() {

    # the home-manager configuration the HM_CONFIG_ACTIVE variable to check for installation state
    [ -z "$HM_CONFIG_ACTIVE" ] || { echo "Home Manager configuration already installed."; return; }

    # Ask if user wants to install Home Manager
    echo "Do you want to install the Home Manager configuration? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Skipping Home Manager install."
        return 0
    fi

    # We first check that Nix is installed on the machine
    if ! command -v nix-env > /dev/null; then
        echo "Nix is not installed on the machine. Nix is required to install Home Manager."
        echo "Do you want to install Nix? (y/n)"
        read -r response
        if [ "$response" = "y" ]; then
            nix_install || return 1
        else
            echo "Skipping Home Manager install."
            return 0
        fi
    fi

    # We start by symlinking the Home Manager configuration
    ln -sf $(pwd)/nixconfig $HOME/.config/home-manager

    # Check if Home Manager is already installed
    if command -v home-manager >/dev/null; then
        # Add the Home Manager channel
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update || 

        # This next line installs home-manager but also installs our configuration
        nix-shell '<home-manager>' -A install || { echo "Home Manager installation failed."; return 1; }
    else
        home-manager switch || { echo "Home Manager installation failed."; return 1; }
    fi
    echo "Home Manager installed successfully."
    echo "To update the Home Manager configuration, run 'home-manager switch'."
}

nixos_system_install
home_manager_install
