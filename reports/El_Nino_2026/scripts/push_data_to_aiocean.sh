#!/usr/bin/env bash
# Push the data downloaded for the Line 66.7 El Niño report to the AIOcean
# Google Drive (rclone remote "AIOcean").  Safe to re-run: rclone copy only
# uploads new or changed files and never deletes anything on the remote.
#
# Remote layout (under AIOcean:data/Spray/):
#   CUGN/Line_66/                 glider data: binnedCUGN66.nc, DAC/, products/
#   El_Nino_2026/CCS/             ONI, SCTI, CUTI/BEUTI, CO-OPS tide gauges ($OS_CCS)
#   El_Nino_2026/SST/OISST/       OISST v2.1 yearly CCS subsets (cugn.oisst)
#
# Usage:  bash reports/El_Nino_2026/scripts/push_data_to_aiocean.sh [--dry-run]
# Written by JXP and Claude, 2026-09-12.
set -euo pipefail

REMOTE=AIOcean:data/Spray
OS_SPRAY=${OS_SPRAY:-/home/xavier/Oceanography/data/Spray/}
OS_CCS=${OS_CCS:-/home/xavier/Oceanography/data/CCS/}
OISST_DIR=$(dirname "${OS_SPRAY%/}")/SST/OISST

OPTS=(--drive-chunk-size 64M --transfers 4 --checkers 8 --stats-one-line -v "$@")

echo "== glider data -> $REMOTE/CUGN/Line_66"
rclone copy "${OS_SPRAY%/}/CUGN/Line_66" "$REMOTE/CUGN/Line_66" "${OPTS[@]}"

echo "== CCS indices -> $REMOTE/El_Nino_2026/CCS"
rclone copy "${OS_CCS%/}" "$REMOTE/El_Nino_2026/CCS" "${OPTS[@]}"

echo "== OISST -> $REMOTE/El_Nino_2026/SST/OISST"
rclone copy "$OISST_DIR" "$REMOTE/El_Nino_2026/SST/OISST" \
    --include 'oisst_ccs_*.nc' "${OPTS[@]}"

echo "== verify"
rclone check "${OS_SPRAY%/}/CUGN/Line_66" "$REMOTE/CUGN/Line_66" --one-way --size-only
rclone check "${OS_CCS%/}" "$REMOTE/El_Nino_2026/CCS" --one-way --size-only
rclone check "$OISST_DIR" "$REMOTE/El_Nino_2026/SST/OISST" --one-way --size-only --include 'oisst_ccs_*.nc'
echo "done"
