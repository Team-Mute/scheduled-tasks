#!/bin/bash
set -euo pipefail

# --- load .env ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "[ERROR] .env 파일이 없습니다: $ENV_FILE"
  exit 1
fi
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# 필수 변수 확인
required_vars=(DBHOST DBPORT DBNAME DBUSER SQL_DIR)
for v in "${required_vars[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    echo "[ERROR] $v 값이 비었습니다. .env를 확인하세요: $v"
    exit 1
  fi
done

# 로그
LOG_DIR="$HOME/job_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/update_reservations_reject.log"

echo "[$(date '+%F %T')] Start (reject)" | tee -a "$LOG_FILE"

if ! command -v pg_isready >/dev/null 2>&1; then
  echo "pg_isready가 없습니다. postgresql-client 패키지를 설치하세요: sudo apt install -y postgresql-client" | tee -a "$LOG_FILE"
  exit 1
fi

if ! pg_isready -h "$DBHOST" -p "$DBPORT" -d "$DBNAME" -t 3 >/dev/null 2>&1; then
  echo "PostgreSQL 서버가 준비되지 않았습니다. ( $DBHOST:$DBPORT )" | tee -a "$LOG_FILE"
  exit 1
fi

psql "host=$DBHOST port=$DBPORT dbname=$DBNAME user=$DBUSER $SSL_OPT" \
  -v ON_ERROR_STOP=1 -c "SET client_encoding TO 'UTF8';" >> "$LOG_FILE" 2>&1

psql "host=$DBHOST port=$DBPORT dbname=$DBNAME user=$DBUSER $SSL_OPT" \
  -v ON_ERROR_STOP=1 -f "$REJECT_SQL_FILE" >> "$LOG_FILE" 2>&1

echo "[$(date '+%F %T')] Done (reject)" | tee -a "$LOG_FILE"