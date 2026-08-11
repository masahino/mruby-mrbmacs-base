#!/usr/bin/env bash
# Line comment, keyword, parameter, scalar, number, and operators.
set -euo pipefail

readonly PROJECT_NAME="mrbmacs"
count=17
output_dir="${TMPDIR:-/tmp}/${PROJECT_NAME}"

greet() {
  local name=${1:-world}
  printf 'hello %s (%d)\n' "$name" "$count"
}

if [[ -n "$PROJECT_NAME" && $count -gt 0 ]]; then
  greet "$PROJECT_NAME"
fi

# Command substitution and backticks.
today=$(date +%F)
legacy=`printf legacy`

# Quoted and unquoted heredocs.
cat <<EOF
project=$PROJECT_NAME
date=$today
EOF

cat <<'LITERAL'
$PROJECT_NAME is not expanded here.
LITERAL

# Intentionally unterminated string for SCE_SH_ERROR.
printf "unterminated
