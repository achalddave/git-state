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

git_state_dir=$(readlink -f "$1")
git_repo=$(readlink -f "$2")
output_git_repo=$(readlink -f "$3")

if [[ -d "${output_git_repo}" ]] ; then
    echo "Output directory (${output_git_repo}) is not empty" >&2
    exit 1
fi

if [[ ! -f "${git_state_dir}/git-head.txt" ]] ; then
    error "Could not find git-head.txt in ${git_state_dir}"
elif [[ ! -f "${git_state_dir}/git-diff.patch" ]] ; then
    error "Could not find git-diff.patch in ${git_state_dir}"
fi

if [[ ! -d "${git_repo}/.git" ]] ; then
    error "${git_repo} is not a git repo."
fi

cd ${git_repo}
git worktree add --detach ${output_git_repo} >/dev/null 2>&1

cd ${output_git_repo}

commit_id=$(cat ${git_state_dir}/git-head.txt)
git checkout ${commit_id} >/dev/null 2>&1
echo "=> Checked out ${commit_id}"

git apply ${git_state_dir}/git-diff.patch >/dev/null 2>&1
echo "=> Applied git diff patch"

echo "Git state is loaded and ready at ${output_git_repo}"
