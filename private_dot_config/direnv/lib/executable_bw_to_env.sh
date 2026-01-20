#!/bin/bash

function bw_env() {
  if [[ "$#" -lt 2 ]]; then
    echo "You must specify at least one folder and one secret name" >&2
    exit 1
  fi

  if [[ -z $BW_SESSION ]]; then
    echo "Failed to log into bitwarden. Ensure you're logged in with bw login, and check your password" >&2
    bw_auth
    #BW_LOCAL=1
    #local BW_SESSION=$(bw unlock --raw)
  fi

  local folder=$1
  shift

  echo "Looking up in $folder"

  # Retrieve the folder id
  local FOLDER_ID=$(bw list folders --search "$folder" --session "$BW_SESSION" | jq -r '.[0].id')

  if [[ -z "$FOLDER_ID" || "$FOLDER_ID" = "null" ]]; then
    echo "Failed to find the folder $folder. Please check if it exists and sync if needed with 'bw sync'" >&2
    exit 1
  fi

  for environment_variable_name in "$@"; do
    local CREDENTIAL=$(bw list items --folderid $FOLDER_ID --search $environment_variable_name --session "$BW_SESSION" | jq -r '.[0].login.password')
    if [[ -z $CREDENTIAL || $CREDENTIAL = "null" ]]; then
      echo "❌️ Failed to retrieve credential for $environment_variable_name in $folder, exiting with error" >&2
      exit 1
    fi

    export "$environment_variable_name=$CREDENTIAL"
    echo "✅️ Exported $environment_variable_name"
  done

  if [[ -n $BW_LOCAL ]]; then
    bw lock
  fi
}
