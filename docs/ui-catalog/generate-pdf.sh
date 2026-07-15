#!/usr/bin/env bash
# Generate MEMBER_APP_UI_CATALOG.pdf from the HTML wireframe catalog.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Generating MEMBER_APP_UI_CATALOG.pdf ..."
node "$SCRIPT_DIR/generate-pdf.mjs"
