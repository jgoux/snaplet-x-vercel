#!/usr/bin/env bash

readonly vercel_project_api_endpoint="https://api.vercel.com/v9/projects/${VERCEL_PROJECT_ID}"
readonly vercel_auth_header="Authorization: Bearer ${VERCEL_ACCESS_TOKEN}"

install_deps() {
  curl -sL "https://app.snaplet.dev/get-cli/" | bash &> "/dev/null"
}

delete_database() {
  snaplet database delete --git --latest
}

extract_deploy_hook_id() {
  local readonly project="${1}"
  jq -r -c ".link.deployHooks[] | select(.ref == \"${GIT_BRANCH}\") | .id" <<< "${project}"
}

extract_env_id() {
  local readonly project="${1}"
  jq -r -c ".env[] | select (.gitBranch == \"${GIT_BRANCH}\") | .id" <<< "${project}"
}

fetch_project() {
  curl -sS -H "${vercel_auth_header}" "${vercel_project_api_endpoint}"
}

delete_deploy_hook() {
  local readonly deploy_hook_id="${1}"
  curl -sS -o "/dev/null" \
    -X "DELETE" "${vercel_project_api_endpoint}/deploy-hooks/${deploy_hook_id}" \
    -H "${vercel_auth_header}"
}

delete_env() {
  local readonly env_id="${1}"
  curl -sS -o "/dev/null" \
    -X "DELETE" "${vercel_project_api_endpoint}/env/${env_id}" \
    -H "${vercel_auth_header}"
}

echo "Installing dependencies..."
install_deps
echo "Dependencies installed."

echo "Deleting database..."
delete_database
echo "Database deleted."
