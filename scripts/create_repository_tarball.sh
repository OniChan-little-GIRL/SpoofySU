#!/usr/bin/env bash
set -euo pipefail

# Create a clean gzip-compressed tar archive from this repository.

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

prefix="${ARCHIVE_PREFIX:-SpoofySU/}"
output="${1:-SpoofySU-repository.tar.gz}"

case "$output" in
  *.tar.gz) ;;
  *)
    printf 'Refusing output name %s: use a .tar.gz extension.\n' "$output" >&2
    exit 2
    ;;
esac

tmp="$(mktemp "${TMPDIR:-/tmp}/spoofysu-tarball.XXXXXX")"
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

# git archive keeps generated artifacts out of the snapshot when paired with
# .gitattributes export-ignore rules.
git archive --worktree-attributes --format=tar --prefix="$prefix" HEAD | gzip -n > "$tmp"
mv "$tmp" "$output"
trap - EXIT

sha256sum "$output" > "$output.sha256"

printf 'Created %s.\n' "$output"
printf 'Verify with: tar -tzf %q | sed -n '\''1,12p'\''\n' "$output"
printf 'Checksum: %s.sha256\n' "$output"
