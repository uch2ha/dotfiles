# add: fetch GitHub skill folders into the inbox

The arguments after `add` are one or more URLs, separated by spaces or newlines (a pasted list works). All fetched items go into one inbox run. Accepted: a GitHub repo root (`https://github.com/<o>/<r>`) or folder (`https://github.com/<o>/<r>/tree/<ref>/<path>`). Anything else → tell the user it's not supported and skip it.

Per URL:
1. Parse `<o>`, `<r>`, `<ref>` (repo root: the default branch, `HEAD`) and `<path>` (repo root: empty).
2. Clone into a fresh temp dir under the scratchpad, without checking out files: `git clone --depth 1 --filter=blob:none --no-checkout [--branch <ref>] https://github.com/<o>/<r>.git <tmp>`, then `git -C <tmp> sparse-checkout set --no-cone <path>` (skip for repo root) and `git -C <tmp> checkout`. Cloning never runs repo code; run nothing from `<tmp>`.
3. `commit` = `git -C <tmp> rev-parse HEAD`.
4. `license` = `spdx_id` only, from `curl -s https://api.github.com/repos/<o>/<r>/license` parsed with `python3 -c`; missing or `NOASSERTION` → `none` (flagged red later).
5. Items: `<tmp>/<path>` has a SKILL.md → that folder is the one item. Otherwise every folder below it with a SKILL.md is an item.
6. Per item: target `agent/skills-alchemy/data/<folder name>/`. Already exists → ask (replace / skip). Copy the whole folder (`cp -r`), then write `.source.json` there: `{"repo": "github.com/<o>/<r>", "path": "<item path in repo>", "commit": "<sha>", "license": "<spdx>", "fetched": "<today>"}`.
7. Delete `<tmp>`.

Then list what was fetched (item, repo, commit short sha, license; a path under a draft-looking folder such as `in-progress/`, `experimental/` or `wip/` gets the note "unstable path, may move upstream") and continue with [inbox.md](inbox.md).
