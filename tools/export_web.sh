#!/usr/bin/env bash
# Веб-сборка для itch.io и Ludum Dare: экспорт пресета Web + патч под песочницу LD + zip.
# LD-embed запрещает service worker'ы: по их гайду заменяем проверки "serviceWorker" in navigator на false.
# IndexedDB там тоже нет — Godot сам падает на память (user:// живёт до перезагрузки страницы).
# Использование: tools/export_web.sh [путь_к_zip]  (по умолчанию build/memory-web.zip)
set -euo pipefail
cd "$(dirname "$0")/.."
out="${1:-build/memory-web.zip}"
dir="build/web"
rm -rf "$dir" && mkdir -p "$dir"
godot --headless --path . --export-release Web "$dir/index.html"
perl -pi -e 's/"serviceWorker"\s*in\s*navigator/false/g; s/'"'"'serviceWorker'"'"'\s*in\s*navigator/false/g' "$dir/index.js" "$dir/index.html"
if grep -q 'serviceWorker"\s*in navigator' "$dir/index.js" "$dir/index.html"; then echo "patch failed" >&2; exit 1; fi
rm -f "$out"
(cd "$dir" && zip -qr -X "$OLDPWD/$out" . -x '.*')
echo "OK: $out ($(du -h "$out" | cut -f1))"
