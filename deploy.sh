#!/usr/bin/env bash

readonly vercel_project_api_endpoint="https://api.vercel.com/v9/projects/${VERCEL_PROJECT_ID}"
readonly vercel_auth_header="Authorization: Bearer ${VERCEL_ACCESS_TOKEN}"

install_deps() {
  curl -sL "https://app.snaplet.dev/get-cli/" | bash
}

create_database() {
  snaplet database create --git --latest
}

extract_deploy_hook_url() {
  local readonly project="${1}"
  jq -r -c ".link.deployHooks[] | select(.name == \"${GIT_BRANCH}\") | .url" <<< "${project}"
}

fetch_project() {
  curl -sS -H "${vercel_auth_header}" "${vercel_project_api_endpoint}"
}

create_deploy_hook() {
  curl -sS \
    -X "POST" "${vercel_project_api_endpoint}/deploy-hooks" \
    -H "${vercel_auth_header}" \
    -H "Content-Type: application/json" \
    --data '{
      "ref": "'"${GIT_BRANCH}"'",
      "name": "'"${GIT_BRANCH}"'"
    }'
}

create_env() {
  local readonly database_url=$(snaplet database url --git)
  curl -sS -o "/dev/null" -X "POST" "${vercel_project_api_endpoint}/env" \
    -H 'Content-Type: application/json' \
    -H "${VERCEL_ACCESS_TOKEN}" \
    --data '{
      "target": "preview",
      "gitBranch": "'"${GIT_BRANCH}"'",
      "type": "encrypted",
      "key": "DATABASE_URL",
      "value": "'"${database_url}"'"
    }'
}

create_deployment() {
  local readonly deploy_hook_url="${1}"
  curl -sS -o "/dev/null" -X "POST" "${deploy_hook_url}"
}

echo "Installing dependencies..."
install_deps
echo "Dependencies installed."

echo "Creating database..."
create_database
echo "Database created."

deploy_hook_url=$(extract_deploy_hook_url "$(fetch_project)" || echo "")

if [ "${deploy_hook_url}" == "" ]; then
  echo "This is a new Pull Request!"

  echo "Creating deploy hook..."
  deploy_hook_url=$(extract_deploy_hook_url "$(create_deploy_hook)" || echo "")
  echo "Deploy hook created."

  echo "Creating environment..."
  create_env
  echo "Environment created."
fi

echo "Creating deployment..."
create_deployment "${deploy_hook_url}"
echo "Deployment created."
