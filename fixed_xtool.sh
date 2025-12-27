#!/bin/bash
# Install Swift dependencies if needed
if ! ldconfig -p | grep -q libncurses.so.6; then
    echo "Installing libncurses6..."
    sudo apt-get update && sudo apt-get install -y libncurses6
fi

# Set up temp directory
export TMPDIR="$HOME/tmp"
mkdir -p "$TMPDIR"

# Set up Swift PATH (using Swift 6.2.3 for Xcode 26.2 compatibility)
export PATH="$HOME/swift_install/swift-6.2.3-RELEASE-ubuntu24.04/usr/bin:$PATH"

# Run xtool with all arguments
exec ~/squashfs-root/usr/bin/xtool "$@"
