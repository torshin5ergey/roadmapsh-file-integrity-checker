#!/bin/bash
set -e

HASH_STORE="${HOME}/.log-integrity"
DEFAULT_HASH_FILE="${HASH_STORE}/hashes.sha256"

# Create hash store directory
mkdir -p "$HASH_STORE"

show_help() {
cat << EOF
integrity-check - verify the integrity of log files to detect tampering

Usage:
  init [PATH]   create new hash
  check [PATH]  verify hash
  update [PATH] update existing hash
EOF
}

# Router
case "$1" in
  init|-init|--init)
  echo "init"
  echo $1 $2 $3
  TARGET="$(realpath "$2")"
  if [ -n "$3" ]; then
    HASH_FILE="$3"
  else
    HASH_FILE="$DEFAULT_HASH_FILE"
  fi

  # Directory
  if [ -d "$TARGET" ]; then
    find "$TARGET" -type f ! -name "*.sha256" -print0 | xargs -0 sha256sum > "$HASH_FILE"
  # Single file
  elif [ -f "$TARGET" ]; then
    sha256sum "$TARGET" > "$HASH_FILE"
  else
    echo "Invalid target: $TARGET"
    exit 1
  fi

  chmod 600 "$HASH_FILE"
  echo "Hashes stored successfully in $HASH_FILE."
  echo "$(wc -l < "$HASH_FILE") files monitored."
  ;;

  check|-check|--check)
  echo "check"
  echo $1 $2 $3
  TARGET="$(realpath "$2")"
  if [ -n "$3" ]; then
    HASH_FILE="$3"
  else
    HASH_FILE="$DEFAULT_HASH_FILE"
  fi

  # Validate hash file
  [ -f "$HASH_FILE" ] || { echo "Missing hash file. Run 'init' first."; exit 1; }

  # Create temp file with stored hash for target file
  TMP_FILE="$(mktemp)"
  grep -F "$TARGET" "$HASH_FILE" > "$TMP_FILE" || true
  # Check if target exists in stored hash
  if [ ! -s "$TMP_FILE" ]; then
    echo "Target not in stored hash file. Use 'init' first."
    rm $"$TMP_FILE"
    exit 1
  fi

  INTEGRITY_ERRORS=0

  while IFS= read -r LINE; do
    echo $LINE
    CUR_FILE_PATH="${LINE##* }" # Keep only path
    echo $CUR_FILE_PATH
    # Hash stored but file didn't exists now
    if [ ! -f "$CUR_FILE_PATH" ]; then
      echo "Missing or removed file: $CUR_FILE_PATH"
      INTEGRITY_ERRORS=1
      continue
    fi
    # Compute current file hash
    if ! sha256sum --check --status <<< "$LINE"; then
      echo "Modified file: $CUR_FILE_PATH"
      INTEGRITY_ERRORS=1
    fi
  done < "$TMP_FILE" # Read every line in while loop
  rm "$TMP_FILE"

  if [ $INTEGRITY_ERRORS -eq 0 ]; then
    echo "Status: Unmodified."
  else
    exit 1
  fi
  ;;

  update|-update|--update)
  echo "update"
  ;;

  *)
  show_help
  exit 1
  ;;
esac
