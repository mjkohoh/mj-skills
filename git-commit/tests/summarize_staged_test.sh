#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPT="$SKILL_DIR/scripts/summarize_staged.sh"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

run_case() {
  local name="$1"
  local file="$2"
  local expected_status="$3"
  local repo="$TMP_DIR/$name"
  local output

  mkdir -p "$repo"
  git -C "$repo" init -q
  printf "TOKEN=example\n" > "$repo/$file"
  git -C "$repo" add -- "$file"

  output="$(cd "$repo" && bash "$SCRIPT")"

  if ! grep -q "^STATUS: $expected_status$" <<< "$output"; then
    printf "FAIL: %s\nExpected STATUS: %s\nActual output:\n%s\n" \
      "$name" "$expected_status" "$output"
    return 1
  fi
}

run_case "allows-env-example" ".env.example" "ok"
run_case "allows-env-production-example" ".env.production.example" "ok"
run_case "blocks-env" ".env" "blocked_sensitive_files"
run_case "blocks-env-local" ".env.local" "blocked_sensitive_files"

echo "PASS: summarize_staged sensitive file rules"
