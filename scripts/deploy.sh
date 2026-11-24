#!/usr/bin/env bash
# Deploy the artifact produced by the Jenkins pipeline.
# No sudo and no systemd, so it runs in a Codespace or any plain Linux box.
set -euo pipefail

ARTIFACT="${1:?usage: deploy.sh <artifact.tar.gz>}"
DEPLOY_ROOT="${HOME}/devops-lab1-deploy"
RELEASE="${DEPLOY_ROOT}/releases/$(date +%Y%m%d%H%M%S)"

echo "[deploy] unpacking ${ARTIFACT} into ${RELEASE}"
mkdir -p "${RELEASE}"
tar -xzf "${ARTIFACT}" -C "${RELEASE}"

echo "[deploy] building the runtime environment"
python3 -m venv "${RELEASE}/.venv"
"${RELEASE}/.venv/bin/pip" install --quiet -r "${RELEASE}/requirements.txt"

echo "[deploy] switching the current symlink"
ln -sfn "${RELEASE}" "${DEPLOY_ROOT}/current"

echo "[deploy] restarting the application"
pkill -f "gunicorn --bind 0.0.0.0:8000" || true
sleep 1
"${RELEASE}/.venv/bin/gunicorn" --bind 0.0.0.0:8000 --workers 2 \
    --chdir "${RELEASE}" --daemon \
    --pid "${DEPLOY_ROOT}/gunicorn.pid" app.main:app

echo "[deploy] keeping the last three releases"
cd "${DEPLOY_ROOT}/releases" && ls -1tr | head -n -3 | xargs -r rm -rf

echo "[deploy] done"
