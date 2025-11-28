#!/usr/bin/env bash

# INTENT: Полностью готовит окружение Railway: пакеты, исходники GLPI и конфиг nginx.
# RESPONSIBILITIES: установить зависимости, синхронизировать файлы, развернуть конфигурацию веб-сервера.
# SIDE_EFFECTS: apt-get install, копирование исходников в /var/www/html и изменение /etc/nginx.

set -euo pipefail
export PATH="/usr/sbin:/sbin:${PATH}"

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_ROOT}/.." && pwd)"
GLPI_SRC="${APP_ROOT}/glpi"
GLPI_DEST="/var/www/html/glpi"
NGINX_CONF_TARGET="/etc/nginx/conf.d/glpi.conf"

install_dependencies() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "[bootstrap-runtime] apt-get недоступен, пропускаем установку пакетов" >&2
    return
  fi

  local packages=(nginx php-fpm rsync)
  echo "[bootstrap-runtime] Устанавливаем пакеты: ${packages[*]}" >&2
  apt-get update -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
}

sync_glpi_sources() {
  if [[ ! -d "${GLPI_SRC}" ]]; then
    echo "[bootstrap-runtime] Не найден каталог GLPI по пути ${GLPI_SRC}" >&2
    exit 1
  fi

  mkdir -p "${GLPI_DEST}"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${GLPI_SRC}/" "${GLPI_DEST}/"
  else
    rm -rf "${GLPI_DEST}"
    mkdir -p "${GLPI_DEST}"
    cp -a "${GLPI_SRC}/." "${GLPI_DEST}/"
  fi

  chown -R www-data:www-data "${GLPI_DEST}"
  chmod -R 755 "${GLPI_DEST}"
  echo "[bootstrap-runtime] GLPI синхронизирован в ${GLPI_DEST}" >&2
}

configure_nginx() {
  if [[ ! -f "${APP_ROOT}/nginx.conf" ]]; then
    echo "[bootstrap-runtime] Не найден nginx.conf в репозитории" >&2
    exit 1
  fi

  install -d /etc/nginx/conf.d
  cp "${APP_ROOT}/nginx.conf" "${NGINX_CONF_TARGET}"

  rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true
  rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

  echo "[bootstrap-runtime] Конфигурация nginx обновлена (${NGINX_CONF_TARGET})" >&2
}

install_dependencies
sync_glpi_sources
configure_nginx
echo "[bootstrap-runtime] Готово" >&2

