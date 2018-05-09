#!/bin/bash

set -e

function usage() {
    echo "Usage: $0 <git_state_dir> <source_git_repo> <output_dir>"
}

function error() {
    echo $* >&2
    exit 1
}

if [[ "$#" < 3 ]] ; then
    error $(usage)
fi

git_state_dir=$(readlink -f "$1" || error "$1 does not exist.")
git_repo=$(readlink -f "$2" || error "$2 does not exist.")
output_git_repo=$(readlink -m "$3" || error "$3 does not exist.")

if [[ -d "${output_git_repo}" ]] ; then
    error "Output directory (${output_git_repo}) is not empty"
fi

if [[ ! -f "${git_state_dir}/git-head.txt" ]] ; then
    error "Could not find git-head.txt in ${git_state_dir}"
elif [[ ! -f "${git_state_dir}/git-diff.patch" ]] ; then
    error "Could not find git-diff.patch in ${git_state_dir}"
fi

cd ${git_repo}
if [[ ! -d ".git" ]] && ! git rev-parse --git-dir >/dev/null 2>&1 ; then
    error "${git_repo} is not a git repo."
fi

git worktree add --detach ${output_git_repo} >/dev/null

cd ${output_git_repo}

commit_id=$(cat ${git_state_dir}/git-head.txt)
git checkout ${commit_id} >/dev/null
echo "=> Checked out ${commit_id}"

git apply ${git_state_dir}/git-diff.patch >/dev/null
echo "=> Applied git diff patch"

echo "Git state is loaded and ready at ${output_git_repo}"
