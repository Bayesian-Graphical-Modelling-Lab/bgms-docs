#!/usr/bin/env bash
#
# Publish a rendered site to the bgms gh-pages branch.
#
# Two channels, one invariant:
#
#   release   replace the branch ROOT with the render, deleting whatever the
#             render no longer produces, but never touching dev/ or any
#             archived vX.Y.Z/ directory.
#   dev       replace dev/ with the render, and touch nothing outside it.
#
# Why this is a script and not peaceiris/actions-gh-pages. That action cleans
# its destination with `git rm -r --ignore-unmatch *` before copying, and the
# destination is the whole clone unless destination_dir is set (see setRepo in
# its src/git-utils.ts). So it can express the dev deploy, but a root deploy
# through it would delete dev/ and every vX.Y.Z/ archive; exclude_assets filters
# the source, not the destination, so there is no way to protect them. One
# script for both channels keeps the invariant in one readable place and lets
# scripts/simulate-deploy.sh exercise the real code.
#
# Usage:
#
#   scripts/deploy-gh-pages.sh release
#   scripts/deploy-gh-pages.sh dev
#
# Environment:
#
#   DEPLOY_REPO        remote to publish to (default: the bgms repository)
#   DEPLOY_BRANCH      branch to publish to (default: gh-pages)
#   DEPLOY_SOURCE      rendered site to publish (default: docs)
#   DEPLOY_KEY         SSH private key with write access to DEPLOY_REPO; when
#                      unset, whatever credentials git already has are used
#   DEPLOY_MESSAGE     commit message
#   DEPLOY_USER_NAME   commit author name
#   DEPLOY_USER_EMAIL  commit author email
#
# The defaults are what CI uses. The variables exist so scripts/simulate-deploy.sh
# can run this same file against a throwaway local repository.

set -euo pipefail

channel="${1:-}"
case "$channel" in
  release|dev) ;;
  *)
    echo "usage: $0 <release|dev>" >&2
    exit 2
    ;;
esac

repo="${DEPLOY_REPO:-git@github.com:Bayesian-Graphical-Modelling-Lab/bgms.git}"
branch="${DEPLOY_BRANCH:-gh-pages}"
source_dir="${DEPLOY_SOURCE:-docs}"
message="${DEPLOY_MESSAGE:-Deploy bgms-docs (${channel})}"
user_name="${DEPLOY_USER_NAME:-bgms-docs deploy}"
user_email="${DEPLOY_USER_EMAIL:-actions@github.com}"

# The development build's directory under the site root. Keep in step with
# DOC_DEV_DIR in scripts/doc-build.R.
dev_dir="dev"

if [ ! -d "$source_dir" ]; then
  echo "deploy: no rendered site at $source_dir; render before deploying" >&2
  exit 1
fi

# GitHub Pages runs Jekyll unless told otherwise, and Jekyll drops paths that
# start with an underscore.
touch "$source_dir/.nojekyll"

if [ -n "${DEPLOY_KEY:-}" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  printf '%s\n' "$DEPLOY_KEY" > "$HOME/.ssh/bgms_deploy_key"
  chmod 600 "$HOME/.ssh/bgms_deploy_key"
  ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/bgms_deploy_key -o IdentitiesOnly=yes"
fi

work="$(mktemp -d)"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

git clone --quiet --depth 1 --single-branch --branch "$branch" "$repo" "$work"

case "$channel" in
  release)
    # Clear the branch root, keeping git's own directory, the development
    # build, and every archived release. Deleting first and copying second is
    # what makes the deploy a replacement rather than an overlay, and it makes
    # the protected set explicit: anything not named here goes.
    #
    # The vX.Y.Z pattern is anchored to a digit and to directories, so a root
    # FILE whose name starts with v, such as versions.json, is replaced by the
    # render like any other. A CNAME file, if the site ever gets one, would
    # have to be added here.
    find "$work" -mindepth 1 -maxdepth 1 \
      ! -name '.git' \
      ! \( -type d -name "$dev_dir" \) \
      ! \( -type d -name 'v[0-9]*' \) \
      -exec rm -rf {} +
    rsync -a "$source_dir/" "$work/"
    ;;
  dev)
    # Replace the development build wholesale. Nothing outside dev/ is read or
    # written, so a dev deploy cannot disturb the released documentation.
    rm -rf "${work:?}/$dev_dir"
    mkdir -p "$work/$dev_dir"
    rsync -a "$source_dir/" "$work/$dev_dir/"
    ;;
esac

git -C "$work" add --all

if git -C "$work" diff --cached --quiet; then
  echo "deploy: $branch already matches this render, nothing to publish"
  exit 0
fi

git -C "$work" \
  -c "user.name=$user_name" \
  -c "user.email=$user_email" \
  commit --quiet -m "$message"
git -C "$work" push --quiet origin "$branch"

echo "deploy: published the $channel build to $branch"
