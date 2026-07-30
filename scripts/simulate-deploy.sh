#!/usr/bin/env bash
#
# Proves the deploy invariant on a throwaway repository.
#
#   scripts/simulate-deploy.sh
#
# It builds a synthetic gh-pages branch that already holds a released site, a
# development build under dev/, and an archived release under v0.1.0/, then
# runs the real scripts/deploy-gh-pages.sh against it in both directions and
# checks what moved:
#
#   root deploy   replaces the root, preserves dev/ and v0.1.0/ byte for byte
#   dev deploy    replaces dev/, changes nothing outside it
#
# Nothing here touches the network or the real gh-pages branch. Run it after
# any change to the deploy script.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
deploy="$here/deploy-gh-pages.sh"

ws="$(mktemp -d)"
trap 'rm -rf "$ws"' EXIT

pass=0
fail=0

check() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    printf '  ok    %s\n' "$label"
    pass=$((pass + 1))
  else
    printf '  FAIL  %s\n    expected: %s\n    actual:   %s\n' \
      "$label" "$expected" "$actual"
    fail=$((fail + 1))
  fi
}

# Every tracked path and blob hash under a prefix, as one comparable string.
subtree() {
  git -C "$1" ls-tree -r HEAD | awk -v p="$2" '$4 ~ "^" p {print $3, $4}' | sort
}

# Every tracked path and blob hash NOT under a prefix.
outside() {
  git -C "$1" ls-tree -r HEAD | awk -v p="$2" '$4 !~ "^" p {print $3, $4}' | sort
}

write() {
  mkdir -p "$(dirname "$1")"
  printf '%s\n' "$2" > "$1"
}

echo "== seeding a synthetic gh-pages branch =="

git init --quiet --bare "$ws/remote.git"

seed="$ws/seed"
mkdir -p "$seed"
git init --quiet "$seed"
git -C "$seed" checkout --quiet -b gh-pages

write "$seed/.nojekyll" ""
write "$seed/index.html" "OLD ROOT INDEX"
write "$seed/reference/bgm.html" "OLD ROOT REFERENCE PAGE"
write "$seed/vignettes.html" "OLD ROOT FILE STARTING WITH v"
write "$seed/dev/index.html" "EXISTING DEV INDEX"
write "$seed/dev/guide/retired.html" "EXISTING DEV PAGE"
write "$seed/v0.1.0/index.html" "ARCHIVED 0.1.0 INDEX"
write "$seed/v0.1.0/reference/bgm.html" "ARCHIVED 0.1.0 REFERENCE PAGE"

git -C "$seed" add --all
git -C "$seed" -c user.name=seed -c user.email=seed@example.com \
  commit --quiet -m "synthetic gh-pages"
git -C "$seed" push --quiet "$ws/remote.git" gh-pages

seed_dev="$(subtree "$seed" dev/)"
seed_archive="$(subtree "$seed" v0.1.0/)"

git -C "$seed" ls-tree -r HEAD --name-only | sed 's/^/  /'

echo
echo "== root deploy: a release render replaces the root =="

release="$ws/site-release"
write "$release/index.html" "NEW ROOT INDEX"
write "$release/guide/getting-started.html" "NEW GUIDE PAGE"
write "$release/versions.json" '{"root": "/bgms/"}'

DEPLOY_REPO="file://$ws/remote.git" \
DEPLOY_SOURCE="$release" \
DEPLOY_MESSAGE="simulated release deploy" \
  "$deploy" release

after_root="$ws/after-root"
git clone --quiet --branch gh-pages "$ws/remote.git" "$after_root"
git -C "$after_root" ls-tree -r HEAD --name-only | sed 's/^/  /'

check "the root index is the new render" \
  "NEW ROOT INDEX" "$(cat "$after_root/index.html")"
check "a new root page is published" \
  "NEW GUIDE PAGE" "$(cat "$after_root/guide/getting-started.html")"
check "versions.json reaches the root" \
  '{"root": "/bgms/"}' "$(cat "$after_root/versions.json")"
check "a stale root page is deleted" \
  "absent" "$([ -e "$after_root/reference/bgm.html" ] && echo present || echo absent)"
check "a stale root file named like a version directory is deleted" \
  "absent" "$([ -e "$after_root/vignettes.html" ] && echo present || echo absent)"
check "dev/ survives the root deploy unchanged" \
  "$seed_dev" "$(subtree "$after_root" dev/)"
check "v0.1.0/ survives the root deploy unchanged" \
  "$seed_archive" "$(subtree "$after_root" v0.1.0/)"

echo
echo "== root deploy is idempotent =="

second="$(DEPLOY_REPO="file://$ws/remote.git" DEPLOY_SOURCE="$release" \
  "$deploy" release)"
check "a second identical root deploy publishes nothing" \
  "deploy: gh-pages already matches this render, nothing to publish" "$second"

root_state="$(outside "$after_root" dev/)"

echo
echo "== dev deploy: a development render replaces dev/ only =="

devsite="$ws/site-dev"
write "$devsite/index.html" "NEW DEV INDEX"
write "$devsite/guide/getting-started.html" "NEW DEV GUIDE PAGE"

DEPLOY_REPO="file://$ws/remote.git" \
DEPLOY_SOURCE="$devsite" \
DEPLOY_MESSAGE="simulated dev deploy" \
  "$deploy" dev

after_dev="$ws/after-dev"
git clone --quiet --branch gh-pages "$ws/remote.git" "$after_dev"
git -C "$after_dev" ls-tree -r HEAD --name-only | sed 's/^/  /'

check "dev/ holds the new development render" \
  "NEW DEV INDEX" "$(cat "$after_dev/dev/index.html")"
check "a page the development render dropped is gone from dev/" \
  "absent" "$([ -e "$after_dev/dev/guide/retired.html" ] && echo present || echo absent)"
check "the root is untouched by the dev deploy" \
  "$root_state" "$(outside "$after_dev" dev/)"
check "v0.1.0/ is untouched by the dev deploy" \
  "$seed_archive" "$(subtree "$after_dev" v0.1.0/)"

echo
printf '%d checks passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
