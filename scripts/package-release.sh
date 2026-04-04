#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="$("$ROOT_DIR/scripts/install-app.sh" | tail -n 1)"
RELEASE_DIR="$ROOT_DIR/release"
VERSION="${1:-v0.1.0}"
ARCHIVE_NAME="get-up-stand-up-${VERSION}-macos.zip"
ARCHIVE_PATH="$RELEASE_DIR/$ARCHIVE_NAME"

mkdir -p "$RELEASE_DIR"
rm -f "$ARCHIVE_PATH"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ARCHIVE_PATH"

echo "$ARCHIVE_PATH"
