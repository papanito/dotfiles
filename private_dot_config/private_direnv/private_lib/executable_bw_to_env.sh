#!/bin/bash

# @description: Search for logins in bws
function bws_env() {
  local PROJECT_NAME=""
  local PROJECT_ID=""
  local OPTIND

  while getopts "p:" opt; do
    case "$opt" in
    p) PROJECT_NAME=$OPTARG ;;
    *)
      echo "Usage: bws_env [-p project_name] VAR1 VAR2 ..." >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # If a project name was provided, find its ID
  if [[ -n "$PROJECT_NAME" ]]; then
    PROJECT_ID=$(bws project list | jq -r ".[] | select(.name == \"$PROJECT_NAME\") | .id")

    if [[ -z "$PROJECT_ID" ]]; then
      echo "❌ Project '$PROJECT_NAME' not found" >&2
      return 1
    fi
    echo "📂 Filtering by Project: $PROJECT_NAME ($PROJECT_ID)"
  fi

  # Iterate through requested variables
  for environment_variable_name in "$@"; do
    local QUERY=".[] | select(.key == \"$environment_variable_name\")"

    # Append project filter to the JQ query if ID exists
    if [[ -n "$PROJECT_ID" ]]; then
      QUERY="$QUERY | select(.projectId == \"$PROJECT_ID\")"
    fi

    local SECRET=$(bws secret list | jq -r "$QUERY | .value")

    if [[ -z $SECRET || $SECRET == "null" ]]; then
      echo "❌ Failed to retrieve credential for $environment_variable_name" >&2
      return 1
    fi

    export "$environment_variable_name=$SECRET"
    echo "✅ Exported $environment_variable_name"
  done
}

# @description: Search for logins in bitwarden in a specific folder
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
