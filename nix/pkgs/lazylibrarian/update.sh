#!/usr/bin/env bash
set -euo pipefail

DIR=$(dirname "$0")
FILE="$DIR/versions.json"
GITLAB="https://gitlab.com/api/v4/projects/LazyLibrarian%2FLazyLibrarian"
GITLAB_RAW="https://gitlab.com/LazyLibrarian/LazyLibrarian/-/raw"

# Get latest master commit hash
REV=$(curl -s "$GITLAB/repository/commits?ref_name=master&per_page=1" | jq -r '.[0].id')
echo "Latest master commit: $REV"

# Fetch requirements.txt for pinned dep versions
REQUIREMENTS=$(curl -s "$GITLAB_RAW/$REV/requirements.txt")

fetch_dep_version() {
  echo "$REQUIREMENTS" | grep -E "^${1}==" | head -1 | sed -E 's/.*==([0-9.]+).*/\1/'
}

SLSKD_VER=$(fetch_dep_version "slskd-api")
ISO639_VER=$(fetch_dep_version "iso639-lang")
echo "slskd-api: $SLSKD_VER   iso639-lang: $ISO639_VER"

# Download and hash
fetch_sri() {
  local raw
  raw=$(nix-prefetch-url "$@")
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

LL_HASH=$(fetch_sri --unpack "https://gitlab.com/LazyLibrarian/LazyLibrarian/-/archive/$REV/LazyLibrarian-$REV.tar.gz")
SLSKD_HASH=$(fetch_sri "https://files.pythonhosted.org/packages/source/s/slskd-api/slskd_api-${SLSKD_VER}.tar.gz")
ISO639_HASH=$(fetch_sri "https://files.pythonhosted.org/packages/source/i/iso639-lang/iso639_lang-${ISO639_VER}.tar.gz")

echo "hashes: LL=$LL_HASH  slskd-api=$SLSKD_HASH  iso639-lang=$ISO639_HASH"

cat > "$FILE" <<EOF
{
  "rev": "$REV",
  "hash": "$LL_HASH",
  "slskd-api": {
    "version": "$SLSKD_VER",
    "hash": "$SLSKD_HASH"
  },
  "iso639-lang": {
    "version": "$ISO639_VER",
    "hash": "$ISO639_HASH"
  }
}
EOF

echo "Updated $FILE"
