#!/usr/bin/env bash
set -euo pipefail

# Create a gzip-compressed tar archive from this repository, but write it with a
# .zip filename so hosts that reject .tar.gz names can still carry the output.
# Important: the payload remains a tar.gz archive; only the filename changes.

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

prefix="${ARCHIVE_PREFIX:-SpoofySU/}"
output="${1:-SpoofySU-repository.zip}"

case "$output" in
  *.zip|*.apk) ;;
  *)
    printf 'Refusing output name %s: use a .zip or .apk extension.\n' "$output" >&2
    exit 2
    ;;
esac

tmp="$(mktemp "${TMPDIR:-/tmp}/spoofysu-tarball.XXXXXX")"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

# git archive keeps the generated file out of the snapshot and does not require
# Android/Termux-specific tooling.
git archive --worktree-attributes --format=tar --prefix="$prefix" HEAD | gzip -n > "$tmp"
mv "$tmp" "$output"
trap - EXIT

sha256sum "$output" > "$output.sha256"

printf 'Created %s (tar.gz payload with a .%s filename).\n' "$output" "${output##*.}"
printf 'Verify with: tar -tzf %q | sed -n '\''1,12p'\''\n' "$output"
printf 'Checksum: %s.sha256\n' "$output"
