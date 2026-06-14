#!/usr/bin/env bash
set -euo pipefail

# annotate-build-steps.sh
# Adds/refreshes "# STEP x/x" comments immediately before each Dockerfile
# instruction in Dockerfile/Containerfile files found in the current directory.
#
# Behavior:
# - scans only files in $PWD (non-recursive)
# - targets files named exactly Dockerfile or Containerfile, plus common variants
#   like Dockerfile.dev, Containerfile.prod, foo.Dockerfile, foo.Containerfile
# - removes existing "# STEP n/n" comments before recalculating
# - counts only actual Dockerfile instructions (FROM, ARG, ENV, RUN, ...)
# - ignores blank lines, ordinary comments, and continuation lines
# - preserves parser directives such as "# syntax=" and "# escape="

readonly STEP_COMMENT_RE='^[[:space:]]*#[[:space:]]*STEP[[:space:]]+[0-9]+/[0-9]+[[:space:]]*$'
readonly INSTRUCTION_RE='^[[:space:]]*(FROM|ARG|RUN|CMD|LABEL|MAINTAINER|EXPOSE|ENV|ADD|COPY|ENTRYPOINT|VOLUME|USER|WORKDIR|ONBUILD|STOPSIGNAL|HEALTHCHECK|SHELL)[[:space:]]+.*$'

is_target_file() {
  local name=${1##*/}
  [[ -f "$1" ]] || return 1
  [[ "$name" == "Dockerfile" ]] \
    || [[ "$name" == "Containerfile" ]] \
    || [[ "$name" == Dockerfile.* ]] \
    || [[ "$name" == Containerfile.* ]] \
    || [[ "$name" == *.Dockerfile ]] \
    || [[ "$name" == *.Containerfile ]]
}

strip_existing_step_comments() {
  local src=$1
  local dst=$2
  awk '!match($0, /^[[:space:]]*#[[:space:]]*STEP[[:space:]]+[0-9]+\/[0-9]+[[:space:]]*$/)' "$src" > "$dst"
}

count_steps() {
  local file=$1
  awk '
    BEGIN { IGNORECASE=1; count=0 }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*(FROM|ARG|RUN|CMD|LABEL|MAINTAINER|EXPOSE|ENV|ADD|COPY|ENTRYPOINT|VOLUME|USER|WORKDIR|ONBUILD|STOPSIGNAL|HEALTHCHECK|SHELL)[[:space:]]+/ { count++ }
    END { print count }
  ' "$file"
}

annotate_file() {
  local file=$1
  local dir base tmp_clean tmp_out total
  dir=$(dirname "$file")
  base=$(basename "$file")
  tmp_clean=$(mktemp)
  tmp_out=$(mktemp)

  strip_existing_step_comments "$file" "$tmp_clean"
  total=$(count_steps "$tmp_clean")

  awk -v total="$total" '
    BEGIN { IGNORECASE=1; step=0 }
    {
      if ($0 ~ /^[[:space:]]*(FROM|ARG|RUN|CMD|LABEL|MAINTAINER|EXPOSE|ENV|ADD|COPY|ENTRYPOINT|VOLUME|USER|WORKDIR|ONBUILD|STOPSIGNAL|HEALTHCHECK|SHELL)[[:space:]]+/) {
        step++
        print "# STEP " step "/" total
      }
      print
    }
  ' "$tmp_clean" > "$tmp_out"

  mv "$tmp_out" "$file"
  rm -f "$tmp_clean"
  printf 'Annotated %s (%s steps)\n' "$base" "$total"
}

main() {
  local found=0 file

  shopt -s nullglob
  for file in "$PWD"/*; do
    if is_target_file "$file"; then
      found=1
      annotate_file "$file"
    fi
  done
  shopt -u nullglob

  if [[ $found -eq 0 ]]; then
    echo "No Dockerfile or Containerfile found in $PWD" >&2
    exit 1
  fi
}

main "$@"
