#!/bin/bash

set -e

show_help() {
cat << EOF
integrity-check - verify the integrity of log files to detect tampering

Usage:
  integrity-check
EOF
}

case "$1" in
  #TODO FILES
  init|-init|--init)
  echo "init"
  echo $1 $2 $3
  TARGET=$2
  if [ -n "$3" ]; then
    HASH_FILE="$3"
  else
    HASH_FILE="${HOME}/hashes.sha256"
  fi

  # Directory
  if [ -d "$TARGET" ]; then
    find "$TARGET" -type f ! -name "*.sha256" -print0 | xargs -0 sha256sum > $HASH_FILE

  # Single file
  elif [ -f "$TARGET" ]; then
    sha256sum "$(realpath "$TARGET")" > "$HASH_FILE"
  fi

  echo "Hashes stored successfully in $HASH_FILE."
  ;;

  check|-check|--check)
  echo "check"
  TARGET=$2
  HASH_FILE=$TARGET

  # Directory
  if sha256sum --check --status $HASH_FILE; then
    echo "Status: Unmodified"
  else
    echo "Status: Modified (Hash mismatch)"
    sha256sum --check --quiet $HASH_FILE
  fi
  ;;

  update|-update|--update)
  echo "update"
  ;;

  *)
  show_help
  ;;
esac
