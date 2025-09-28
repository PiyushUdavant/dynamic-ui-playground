#!/usr/bin/env bash
set -euo pipefail

# Deploy Flutter Web build to a separate GitHub repo for GitHub Pages
# Defaults target your existing demo repo. Override via env vars if needed.
#
# Usage:
#   ./scripts/deploy_pages.sh
#   REPO_URL=https://github.com/<user>/<repo>.git REPO_NAME=<repo> BRANCH=main ./scripts/deploy_pages.sh
#
# Notes:
# - This script initializes a Git repo inside build/web and force-pushes to the target branch.
# - Ensure you have push access to REPO_URL and that your git is authenticated.

REPO_URL="${REPO_URL:-https://github.com/JoaoPauloUbaF/dynamic-ui-playground-demo.git}"
REPO_NAME="${REPO_NAME:-dynamic-ui-playground-demo}"
BRANCH="${BRANCH:-main}"
COMMIT_MSG="${COMMIT_MSG:-Publish Flutter web demo}" 
BUILD_DIR="build/web"

info() { printf "[deploy] %s\n" "$*"; }

# 1) Ensure Flutter web is enabled
info "Ensuring Flutter web is enabled"
flutter config --enable-web >/dev/null 2>&1 || true

# 2) Build for web with correct base href for GitHub Pages
info "Building Flutter web app for /${REPO_NAME}/"
flutter build web \
  --release \
  --base-href="/${REPO_NAME}/" \
  --pwa-strategy=offline-first

# 3) Prepare GitHub Pages specifics
info "Preparing GitHub Pages artifacts (.nojekyll, 404.html)"
# Disable Jekyll
printf "# Disable Jekyll on GitHub Pages\n" > "${BUILD_DIR}/.nojekyll"
# SPA fallback: copy index.html to 404.html
cp -f "${BUILD_DIR}/index.html" "${BUILD_DIR}/404.html"

# 4) Initialize repo in build output and push to remote
info "Initializing git repo in ${BUILD_DIR} and pushing to ${REPO_URL} (${BRANCH})"
if [ ! -d "${BUILD_DIR}/.git" ]; then
  git -C "${BUILD_DIR}" init >/dev/null
fi

git -C "${BUILD_DIR}" checkout -B "${BRANCH}"

git -C "${BUILD_DIR}" add .
# Only commit if there are changes
if ! git -C "${BUILD_DIR}" diff --cached --quiet; then
  git -C "${BUILD_DIR}" commit -m "${COMMIT_MSG}"
else
  info "No changes to commit"
fi

# Set remote (idempotent)
if git -C "${BUILD_DIR}" remote get-url origin >/dev/null 2>&1; then
  git -C "${BUILD_DIR}" remote set-url origin "${REPO_URL}"
else
  git -C "${BUILD_DIR}" remote add origin "${REPO_URL}"
fi

# Push force-with-lease to avoid clobbering by accident
info "Pushing to ${BRANCH}"
GIT_TRACE=0 GIT_CURL_VERBOSE=0 git -C "${BUILD_DIR}" push -u --force-with-lease origin "${BRANCH}"

info "Done. Configure GitHub Pages: Settings > Pages > Deploy from a branch: ${BRANCH} / (root)"

