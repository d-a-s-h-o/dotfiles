# ---------------------------- Secret Management ------------------------------

# direnv integration (must be in interactive shells)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# -----------------------------------------------------------------------------
# Secret helpers for Skate + gum.
#
# Usage:
#   secret [-g] [-e env] KEY
#     - By default: uses repo scope if inside a git repo, otherwise global.
#     - -g forces global scope.
#     - -e chooses an environment name (default: dev).
#
#   secret-get [-e env] KEY
#     - Prints the secret to stdout.
#     - Resolution order: repo DB first (if in a repo), then global DB.
#
# Notes:
#   - Skate stores items as: KEY@DB
#   - DBs are named like:
#       global.<env>
#       repo.<repo-slug>.<env>
# -----------------------------------------------------------------------------

_secrets_repo_slug() {
  local top remote slug
  top="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)" || return 1
  remote="$(git -C "$top" remote get-url origin 2>/dev/null || echo "$top")"

  remote="${remote%.git}"
  remote="${remote#git@}"
  remote="${remote#https://}"
  remote="${remote#http://}"
  remote="${remote/:/\/}"

  slug="${remote//\//_}"
  slug="${slug//[^A-Za-z0-9_.-]/_}"
  slug="${slug%%_}"           # strip trailing underscore
  # Finally change all double underscores to single
  slug="${slug//__/_}"

  print -r -- "$slug"
}

_secrets_db_global() { print -r -- "global.$1"; }

_secrets_db_repo() {
  local env="$1" slug
  slug="$(_secrets_repo_slug)" || return 1
  print -r -- "repo.${slug}.${env}"
}

secret() {
  emulate -L zsh
  setopt localoptions pipefail

  local env="dev" scope="auto"
  local OPTIND=1 opt
  while getopts ":ge:" opt; do
    case "$opt" in
      g) scope="global" ;;
      e) env="$OPTARG" ;;
      *) echo "Usage: secret [-g] [-e env] KEY" >&2; return 1 ;;
    esac
  done
  shift $((OPTIND-1))

  local key="$1"
  [[ -z "$key" ]] && { echo "Usage: secret [-g] [-e env] KEY" >&2; return 1; }

  command -v skate >/dev/null 2>&1 || { echo "Missing: skate" >&2; return 1; }
  command -v gum   >/dev/null 2>&1 || { echo "Missing: gum" >&2; return 1; }

  local db
  if [[ "$scope" == "global" ]]; then
    db="$(_secrets_db_global "$env")"
  else
    db="$(_secrets_db_repo "$env" 2>/dev/null)" || db="$(_secrets_db_global "$env")"
  fi

  local value
  value="$(gum input --password --prompt "Enter secret for $key ($db): ")" || return 1
  printf "\n" >&2
  [[ -z "$value" ]] && { echo "Empty value, aborting." >&2; return 1; }

  skate set "${key}@${db}" "$value"
  echo "Stored ${key}@${db}"
}

secret-get() {
  emulate -L zsh
  setopt localoptions pipefail

  local env="dev"
  local OPTIND=1 opt
  while getopts ":e:" opt; do
    case "$opt" in
      e) env="$OPTARG" ;;
      *) echo "Usage: secret-get [-e env] KEY" >&2; return 1 ;;
    esac
  done
  shift $((OPTIND-1))

  local key="$1"
  [[ -z "$key" ]] && { echo "Usage: secret-get [-e env] KEY" >&2; return 1; }
  command -v skate >/dev/null 2>&1 || { echo "Missing: skate" >&2; return 1; }

  local repo_db global_db val
  repo_db="$(_secrets_db_repo "$env" 2>/dev/null)" || repo_db=""
  global_db="$(_secrets_db_global "$env")"

  if [[ -n "$repo_db" ]] && val="$(skate get "${key}@${repo_db}" 2>/dev/null)"; then
    print -r -- "$val"; return 0
  fi
  skate get "${key}@${global_db}"
}
