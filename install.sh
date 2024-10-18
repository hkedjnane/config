#!/bin/sh

set -e

# This script installs the configuration on the current machine.
# There are currently 3 parts to this script:
#   - NixOS system configuration
#   - Home Manager configuration
#   - Neovim configuration


# Run the NixOS/home-manager configuration install
./nixconfig/install.sh

# Other components can be added here
