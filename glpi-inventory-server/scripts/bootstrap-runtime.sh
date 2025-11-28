#!/usr/bin/env bash

# INTENT: Готовит runtime в средах без предустановленных nginx/php-fpm (Railpack/Nixpacks).
# RESPONSIBILITIES: Проверить наличие бинарей и при необходимости установить системные пакеты.
# SIDE_EFFECTS: apt-get update/install (требует root), пишет в stdout/stderr.

set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "[bootstrap-runtime] apt-get недоступен, пропускаем установку зависимостей" >&2
  return 0 2>/dev/null || exit 0
fi

missing=()

command -v nginx >/dev/null 2>&1 || missing+=("nginx")
command -v php-fpm >/dev/null 2>&1 || missing+=("php-fpm")

if [[ ${#missing[@]} -eq 0 ]]; then
  echo "[bootstrap-runtime] nginx и php-fpm уже установлены" >&2
  return 0 2>/dev/null || exit 0
fi

echo "[bootstrap-runtime] Устанавливаем пакеты: ${missing[*]}" >&2
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
echo "[bootstrap-runtime] Готово" >&2

