#!/usr/bin/env bash
# Instalador del SDD Harness para Claude Code.
# Copia los skills y las plantillas a ~/.claude/ (o a $CLAUDE_HOME si está seteado).
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"

echo "Instalando SDD Harness en: $DEST"
mkdir -p "$DEST/skills" "$DEST/sdd"
cp -R "$SRC/skills/." "$DEST/skills/"
cp -R "$SRC/sdd/."    "$DEST/sdd/"

echo "✔ Listo. Abrí una sesión NUEVA de Claude Code y probá:  /sdd-help"
