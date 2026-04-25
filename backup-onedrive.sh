#!/usr/bin/env bash
# Backup do dia anterior para o OneDrive correspondente (dias pares → diasPares, dias ímpares → diaImpar)
# Agendado para rodar às 00:10 via cron.

set -euo pipefail

RECORDINGS_DIR="/home/usua1/frigate/storage/recordings"
LOG_DIR="/var/log/bkp-onedrive"
RCLONE_FLAGS="--transfers=8 --checkers=16 --log-level INFO"

# Dia anterior
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
DAY_NUMBER=$(date -d "yesterday" +%-d)   # sem zero à esquerda

# Escolhe o remote rclone conforme paridade do dia
if (( DAY_NUMBER % 2 == 0 )); then
    REMOTE="diasPares"
else
    REMOTE="diaImpar"
fi

SOURCE="${RECORDINGS_DIR}/${YESTERDAY}"
DEST="${REMOTE}:recordings/${YESTERDAY}"

mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/backup-${YESTERDAY}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log "Iniciando backup: ${SOURCE} → ${DEST}"

if [[ ! -d "${SOURCE}" ]]; then
    log "ERRO: Diretório de origem não encontrado: ${SOURCE}"
    exit 1
fi

rclone copy "${SOURCE}" "${DEST}" ${RCLONE_FLAGS} --log-file "${LOG_FILE}" 2>&1

EXIT_CODE=$?
if [[ ${EXIT_CODE} -eq 0 ]]; then
    log "Backup concluído com sucesso."
else
    log "ERRO: rclone encerrou com código ${EXIT_CODE}."
    exit ${EXIT_CODE}
fi
