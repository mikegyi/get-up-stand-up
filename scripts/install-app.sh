#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="$("$ROOT_DIR/scripts/build-app.sh" | tail -n 1)"
TARGET_DIR="$HOME/Applications"
TARGET_PATH="$TARGET_DIR/Stand Up.app"

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_PATH"
cp -R "$APP_PATH" "$TARGET_PATH"

echo "$TARGET_PATH"
