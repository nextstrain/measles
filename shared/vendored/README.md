# Shared

Shared internal tooling for pathogen workflows. Used by our individual
pathogen repos which produce Nextstrain builds. Expected to be vendored by
each pathogen repo using `git subrepo` similar to https://github.com/nextstrain/ingest.

## Vendoring

Nextstrain maintained pathogen repos will use [`git subrepo`](https://github.com/ingydotnet/git-subrepo)
to vendor shared workflow functions.

If you don't already have `git subrepo` installed, follow the
[git subrepo installation instructions](https://github.com/ingydotnet/git-subrepo#installation).
Then add the latest shared scripts to the pathogen repo by running:

```
git subrepo clone https://github.com/nextstrain/shared shared/vendored
```

Any future updates of shared scripts can be pulled in with:

```
git subrepo pull shared/vendored
```

If you run into merge conflicts and would like to pull in a fresh copy of the
latest shared scripts, pull with the `--force` flag:

```
git subrepo pull shared/vendored --force
```

> **Warning**
> Beware of rebasing/dropping the parent commit of a `git subrepo` update

`git subrepo` relies on metadata in the `shared/vendored/.gitrepo` file,
which includes the hash for the parent commit in the pathogen repos.
If this hash no longer exists in the commit history, there will be errors when
running future `git subrepo pull` commands.

If you run into an error similar to the following:
```
$ git subrepo pull shared/vendored
git-subrepo: Command failed: 'git branch subrepo/shared/vendored '.
fatal: not a valid object name: ''
```
Check the parent commit hash in the `shared/vendored/.gitrepo` file and make
sure the commit exists in the commit history. Update to the appropriate parent
commit hash if needed.
