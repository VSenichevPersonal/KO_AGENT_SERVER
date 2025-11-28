#!/usr/bin/env bash

# INTENT: Запускает связку PHP-FPM + Nginx в одном процессе, управляя их жизненным циклом.
# RESPONSIBILITIES: инициализация сервисов, проброс сигналов, корректное завершение.
# SIDE_EFFECTS: стартует демоны веб-сервера внутри контейнера/VM.

set -euo pipefail

# INTENT: Railway runtime запускается под непривилегированным пользователем,
# у которого по умолчанию нет /usr/sbin в PATH. Добавляем системные пути явно.
export PATH="/usr/sbin:/sbin:${PATH}"

APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${APP_ROOT}"

PHP_FPM_BIN="${PHP_FPM_BIN:-php-fpm}"
NGINX_BIN="${NGINX_BIN:-nginx}"
NGINX_GLOBAL_DIRECTIVES="${NGINX_GLOBAL_DIRECTIVES:-daemon off;}"
read -r -a PHP_FPM_ARGS <<< "${PHP_FPM_FLAGS:--F}"

PHP_PID=""
NGINX_PID=""

wait_for_pid() {
  local pid="$1"
  if [[ -z "${pid}" ]]; then
    return 0
  fi
  if ! kill -0 "${pid}" 2>/dev/null; then
    return 0
  fi
  wait "${pid}" 2>/dev/null || true
}

cleanup() {
  local exit_code=$?
  if kill -0 "${NGINX_PID}" 2>/dev/null; then
    kill "${NGINX_PID}" 2>/dev/null || true
  fi
  if kill -0 "${PHP_PID}" 2>/dev/null; then
    kill "${PHP_PID}" 2>/dev/null || true
  fi
  wait_for_pid "${NGINX_PID}"
  wait_for_pid "${PHP_PID}"
  exit "${exit_code}"
}

trap cleanup EXIT INT TERM

"${PHP_FPM_BIN}" "${PHP_FPM_ARGS[@]}" &
PHP_PID=$!

"${NGINX_BIN}" -g "${NGINX_GLOBAL_DIRECTIVES}" &
NGINX_PID=$!

wait -n "${NGINX_PID}" "${PHP_PID}"
EXIT_CODE=$?

if kill -0 "${NGINX_PID}" 2>/dev/null; then
  kill "${NGINX_PID}" 2>/dev/null || true
fi
if kill -0 "${PHP_PID}" 2>/dev/null; then
  kill "${PHP_PID}" 2>/dev/null || true
fi

wait_for_pid "${NGINX_PID}"
wait_for_pid "${PHP_PID}"

exit "${EXIT_CODE}"

