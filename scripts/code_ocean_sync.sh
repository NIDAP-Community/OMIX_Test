#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/code_ocean_sync.sh outbound MODULE CODE_OCEAN_ROOT [--apply]
  scripts/code_ocean_sync.sh reverse MODULE CODE_OCEAN_ROOT [--apply] [--branch]

MODULE must match an existing modules/<name>/runtime directory in the repo.

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
  echo "Unsupported module: ${module}" >&2
  echo "No runtime directory found at modules/${module}/runtime" >&2
  echo "" >&2
  echo "Available modules:" >&2
  for dir in "${repo_root}/modules"/*/runtime; do
    if [[ -d "${dir}" ]]; then
      echo "  $(basename "$(dirname "${dir}")")" >&2
    fi
  done
  exit 2
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
  --exclude ".git"
  --exclude ".git/"
  --exclude ".github"
  --exclude ".github/"
  --exclude ".codeocean"
  --exclude ".codeocean/"
  --exclude ".DS_Store"
  --exclude ".Rhistory"
  --exclude ".RData"
  --exclude "Rplots.pdf"
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

skip_common_path() {
  local rel_path="$1"
  local base_name
  base_name="$(basename "${rel_path}")"

  case "${rel_path}" in
    .git|.git/*|.github|.github/*|.codeocean|.codeocean/*)
      return 0
      ;;
  esac

  case "${base_name}" in
    .DS_Store|.Rhistory|.RData|Rplots.pdf)
      return 0
      ;;
  esac

  return 1
}

allow_reverse_path() {
  local rel_path="$1"

  case "${rel_path}" in
    results/README.md)
      return 0
      ;;
    results/*)
      return 1
      ;;
    data/README.md|data/example_inputs/*)
      return 0
      ;;
    data/*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

portable_copy() {
  local src_root="$1"
  local dest_root="$2"
  local copy_mode="$3"

  echo "rsync not found; using portable copy fallback." >&2
  (
    cd "${src_root}"
    while IFS= read -r -d '' src_file; do
      local rel_path
      rel_path="${src_file#./}"

      if skip_common_path "${rel_path}"; then
        continue
      fi

      if [[ "${copy_mode}" == "reverse" ]] && ! allow_reverse_path "${rel_path}"; then
        continue
      fi

      if [[ "${apply}" != "--apply" ]]; then
        echo "${rel_path}"
      else
        mkdir -p "${dest_root}/$(dirname "${rel_path}")"
        cp -p "${rel_path}" "${dest_root}/${rel_path}"
      fi
    done < <(find . -type f -print0)
  )
}

sync_tree() {
  local copy_mode="$1"
  local src_root="$2"
  local dest_root="$3"

  if [[ "${OMIX_SYNC_DISABLE_RSYNC:-}" != "1" ]] && command -v rsync >/dev/null 2>&1; then
    if [[ "${copy_mode}" == "outbound" ]]; then
      rsync "${rsync_flags[@]}" "${common_excludes[@]}" "${src_root}/" "${dest_root}/"
    else
      rsync "${rsync_flags[@]}" "${common_excludes[@]}" "${reverse_filters[@]}" "${src_root}/" "${dest_root}/"
    fi
  else
    portable_copy "${src_root}" "${dest_root}" "${copy_mode}"
  fi
}

copy_auto_workflow_to_export() {
  local workflow_src="${repo_root}/.github/workflows/auto-cosync-pr.yml"
  local workflow_dest="${co_root}/.github/workflows/auto-cosync-pr.yml"

  if [[ ! -f "${workflow_src}" ]]; then
    return 0
  fi

  if [[ "${apply}" != "--apply" ]]; then
    echo ".github/workflows/auto-cosync-pr.yml"
  else
    mkdir -p "$(dirname "${workflow_dest}")"
    cp -p "${workflow_src}" "${workflow_dest}"
  fi
}

if [[ "${mode}" == "outbound" ]]; then
  echo "Outbound sync: modules/${module}/runtime -> ${co_root}" >&2
  sync_tree outbound "${module_runtime}" "${co_root}"
  copy_auto_workflow_to_export
else
  branch_name="co-sync/${module}/$(date +%Y%m%d-%H%M%S)"
  echo "Reverse sync: ${co_root} -> modules/${module}/runtime" >&2
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
  sync_tree reverse "${co_root}" "${module_runtime}"
fi
