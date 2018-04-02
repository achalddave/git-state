# Scripts for saving/loading git state

Helper scripts that save the current state of the git repository (including the
current commit id at HEAD, and any changes to tracked files) to an output
directory. These outputs can then be loaded to restore the git repository to the
state it was in when saved.

# `save_git_state.sh`

To save the state of a git repository, run the following command from within the
git repository:

    ./save_git_state.sh /path/to/output/git/state

Optionally, you can specify the path to a git repository:

    ./save_git_state.sh /path/to/output/directory /path/to/git/repo

See [`dump_git_info.sh`](./dump_git_info.sh) for the list of files saved to the
output directory.

Since this is a shell script, you can run it from your favorite language easily.
For example, in python:

# train.py

```python
import subprocess

output_dir = '/path/to/experiment/directory'
subprocess.call(['./dump_git_info.sh', output_dir])

# ...
# Run your code
# ...
```

`output_dir` will then contain the state of your code at the time `train.py` was
run. 


# `load_git_state.sh`

Later, to load the state back, you can use `load_git_state.sh`. This can be used
to reproduce old experiments.


    ./save_git_state.sh <git_state_output> <git_repo> <output_dir>

This will load the git state saved in `<git_state_output>` for the repo in
`<git_repo>` to `<output_dir>`.

Under the hood, this actually creates a
[worktree](https://git-scm.com/docs/git-worktree) in the `<output_dir>`, so that
it is linked to the original git repository.
