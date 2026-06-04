#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/code_ocean_sync.sh outbound MODULE CODE_OCEAN_ROOT [--apply]
  scripts/code_ocean_sync.sh reverse MODULE CODE_OCEAN_ROOT [--apply] [--branch]

MODULE must be one of:
  volcano
  pathway_l2p_single
  pathway_l2p_multi

Default mode is dry-run. Pass --apply to copy files.
For reverse sync, pass --branch with --apply to create a review branch first.
The OMIX module runtime directory is copied to or from the Code Ocean root.
USAGE
}

if [[ $# -lt 3 ]]; then
  usage
  exit 2
fi

mode="$1"
module="$2"
co_root="$3"
apply=""
create_branch="false"

for option in "${@:4}"; do
  case "${option}" in
    --apply)
      apply="--apply"
      ;;
    --branch)
      create_branch="true"
      ;;
    "")
      ;;
    *)
      echo "Unknown option: ${option}" >&2
      usage
      exit 2
      ;;
  esac
done

case "${module}" in
  volcano|pathway_l2p_single|pathway_l2p_multi)
    ;;
  *)
    echo "Unsupported module: ${module}" >&2
    usage
    exit 2
    ;;
esac

case "${mode}" in
  outbound|reverse)
    ;;
  *)
    echo "Unsupported mode: ${mode}" >&2
    usage
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
module_runtime="${repo_root}/modules/${module}/runtime"

if [[ ! -d "${module_runtime}" ]]; then
  echo "Missing module runtime directory: ${module_runtime}" >&2
  exit 1
fi

if [[ ! -d "${co_root}" ]]; then
  echo "Missing Code Ocean root directory: ${co_root}" >&2
  exit 1
fi

rsync_flags=(-av)
if [[ "${apply}" != "--apply" ]]; then
  rsync_flags+=(--dry-run)
  echo "Dry-run only. Re-run with --apply to copy files." >&2
fi

common_excludes=(
  --exclude ".git/"
  --exclude ".codeocean/"
  --exclude ".DS_Store"
  --exclude ".Rhistory"
  --exclude ".RData"
)

reverse_filters=(
  --include "results/"
  --include "results/README.md"
  --exclude "results/**"
  --include "data/"
  --include "data/README.md"
  --include "data/example_inputs/"
  --include "data/example_inputs/**"
  --exclude "data/**"
)

if [[ "${mode}" == "outbound" ]]; then
  rsync "${rsync_flags[@]}" "${common_excludes[@]}" "${module_runtime}/" "${co_root}/"
else
  branch_name="co-sync/${module}/$(date +%Y%m%d-%H%M%S)"
  echo "Reverse sync target: modules/${module}/runtime" >&2
  if [[ "${create_branch}" == "true" ]]; then
    if [[ "${apply}" != "--apply" ]]; then
      echo "Branch requested for dry-run. Branch would be: ${branch_name}" >&2
    else
      if [[ -n "$(git -C "${repo_root}" status --short)" ]]; then
        echo "Refusing to create reverse-sync branch because the worktree is not clean." >&2
        echo "Commit, stash, or review existing changes before applying Code Ocean edits." >&2
        exit 1
      fi
      git -C "${repo_root}" checkout -b "${branch_name}"
    fi
  else
    echo "Recommended branch before applying: ${branch_name}" >&2
  fi
  rsync "${rsync_flags[@]}" "${common_excludes[@]}" "${reverse_filters[@]}" "${co_root}/" "${module_runtime}/"
fi
