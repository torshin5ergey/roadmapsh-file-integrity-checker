#!/bin/bash
set -e

HASH_STORE="${HOME}/.log-integrity"
DEFAULT_HASH_FILE="${HASH_STORE}/hashes.sha256"

# Create hash store directory
mkdir -p "$HASH_STORE"

show_help() {
cat << EOF
integrity-check - Verify the integrity of log files to detect tampering

integrity-check.sh [COMMAND] [TARGET] [OPTIONAL_HASH_FILE]

Commands:
  init      Create new integrity baseline
  check     Verify against stored baseline
  update    Update existing baseline
  help      Show usage information

Arguments:
  TARGET             Directory or file to monitor
  OPTIONAL_HASH_FILE Custom hash file location (default: ~/.log-integrity/hashes.sha256)
EOF
}

# Router
case "$1" in
# init ==========================================
  init|-init|--init)
  TARGET="$(realpath "$2")"
  if [[ -n "$3" ]]; then
    HASH_FILE="$3"
  else
    HASH_FILE="$DEFAULT_HASH_FILE"
  fi

  echo "Hash file $HASH_FILE for $TARGET initializing..."

  # Directory
  if [[ -d "$TARGET" ]]; then
    find "$TARGET" -type f ! -name "*.sha256" -print0 | xargs -0 sha256sum > "$HASH_FILE"
  # Single file
  elif [[ -f "$TARGET" ]]; then
    sha256sum "$TARGET" > "$HASH_FILE"
  else
    echo "Invalid target: $TARGET"
    exit 1
  fi

  chmod 600 "$HASH_FILE"
  echo "Hashes stored successfully in $HASH_FILE."
  echo "$(wc -l < "$HASH_FILE") files monitored."
  ;;

# check =========================================
  check|-check|--check)
  TARGET="$(realpath "$2")"
  if [[ -n "$3" ]]; then
    HASH_FILE="$3"
  else
    HASH_FILE="$DEFAULT_HASH_FILE"
  fi

  # Validate hash file
  if [[ ! -f "$HASH_FILE" ]]; then
    echo "Missing hash file. Run 'init' first."
    exit 1
  fi

  echo "Hash file $HASH_FILE for $TARGET checking..."

  # Create temp file with stored hash for target file
  TMP_FILE="$(mktemp)"
  grep -F "$TARGET" "$HASH_FILE" > "$TMP_FILE" || true
  # Check if target exists in stored hash
  if [[ ! -s "$TMP_FILE" ]]; then
    echo "Target not in stored hash file. Use 'init' first."
    rm $"$TMP_FILE"
    exit 1
  fi

  IS_ERRORS=0

  while IFS= read -r LINE; do
    CUR_FILE_PATH="${LINE##* }" # Keep only path
    # Hash stored but file didn't exists now
    if [[ ! -f "$CUR_FILE_PATH" ]]; then
      echo "Missing or removed file: $CUR_FILE_PATH"
      IS_ERRORS=1
      continue
    fi
    # Compute current file hash
    if ! sha256sum --check --status <<< "$LINE"; then
      echo "Modified file: $CUR_FILE_PATH"
      IS_ERRORS=1
    fi
  done < "$TMP_FILE" # Read every line in while loop
  rm "$TMP_FILE"

  # Check for new files in directory
  if [[ -d "$TARGET" ]]; then
    while IFS= read -r CUR_FILE_PATH; do
      if ! grep -qF "$CUR_FILE_PATH" "$HASH_FILE"; then
        echo "New file: $CUR_FILE_PATH"
	IS_ERRORS=1
      fi
    done < <(find "$TARGET" -type f -print)
  fi

  if [[ $IS_ERRORS -eq 0 ]]; then
    echo "Status: Unmodified."
  else
    echo "Status: Modified."
    exit 1
  fi
  ;;

# update ========================================
  update|-update|--update)
  TARGET="$(realpath "$2")"
  if [[ -n "$3" ]]; then
    HASH_FILE="$3"
  else
    HASH_FILE="$DEFAULT_HASH_FILE"
  fi

  # Validate hash file
  if [[ ! -f "$HASH_FILE" ]]; then
    echo "Missing hash file. Run 'init' first."
    exit 1
  fi

  echo "$HASH_FILE updating..."

  IS_UPDATED=0
  TMP_FILE="$(mktemp)"

  # Update existing files hash
  while IFS= read -r LINE; do
    CUR_FILE_PATH="${LINE##* }" # Keep only path (remove longest substring)
    if [[ "$CUR_FILE_PATH" == "$TARGET" || "$CUR_FILE_PATH" == "${TARGET}/*" ]]; then
      if [[ -f "$CUR_FILE_PATH" ]]; then
        sha256sum "$CUR_FILE_PATH" >> "$TMP_FILE"
	IS_UPDATED=1
      else
        echo "Removed file: $CURRENT_FILE_PATH (skipping)"
      fi
    else
      echo "$LINE" >> "$TMP_FILE"
    fi
  done < "$HASH_FILE"

  # Add new files for directory
  if [[ -d "$TARGET" ]]; then
    while IFS= read -r CUR_FILE_PATH; do
      if ! grep -qF "$CUR_FILE_PATH" "$TMP_FILE"; then
        sha256sum "$CUR_FILE_PATH" >> "$TMP_FILE"
	IS_UPDATED=1
      fi
    done < <(find "$TARGET" -type f -print)
  fi

  mv "$TMP_FILE" "$HASH_FILE"
  if [[ $IS_UPDATED -eq 1 ]]; then
    echo "Status: hash file $HASH_FILE updated."
  else
    echo "Status: No changes detected for $HASH_FILE"
  fi
  ;;

# help ==========================================
  *)
  show_help
  exit 1
  ;;
esac

