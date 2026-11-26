#!/usr/bin/env bash
set -euo pipefail

PLASMOID_ID="com.github.eatsu.spaceume"
INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package"

echo "==> Spaceume installer"
echo "    Installing $PLASMOID_ID to $INSTALL_DIR"

mkdir -p "$INSTALL_DIR"

cp -r "$SOURCE_DIR/." "$INSTALL_DIR/"

echo "    Files installed."

echo "    plasmashell restart skipped."
echo "    NOTE: If plasmashell is not running, start it manually (see below)."
echo "    Do not let the installer restart plasmashell automatically."

echo "==> Done. Add Spaceume to your panel via the 'Add Widgets' dialog."
