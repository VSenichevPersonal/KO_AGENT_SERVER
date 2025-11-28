#!/usr/bin/env bash

# INTENT: Унифицированная точка входа для Railpack/containers, запускает GLPI-стек.
# RESPONSIBILITIES: перейти в рабочий каталог и делегировать запуск сервисов.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}/glpi-inventory-server"
./scripts/bootstrap-runtime.sh
exec ./scripts/run-stack.sh

