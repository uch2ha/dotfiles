# upstream: check filed skills against their source repo

Argument: a skill name, or `all` (default when omitted). Nothing updates without the user's OK; a skipped update shows again next run.

Items: own skills (the global skills dir from Settings, `agent/skills/*/*/`, `agent/skills-alchemy/result/*/`) whose frontmatter has `metadata.source` (repo, path, commit, license). Plugins and personal skills (no `metadata.source`) are out of scope; list the personal ones as skipped. None found → say so and stop.

Per item, with `<o>/<r>` from `repo` and `<old>` = recorded `commit`:
1. `<new>` = `git ls-remote https://github.com/<o>/<r>.git HEAD` (the default branch). `<new>` == `<old>` → up to date.
2. Otherwise clone without file contents into a fresh scratchpad temp dir: `git clone --filter=blob:none --no-checkout https://github.com/<o>/<r>.git <tmp>`. Run nothing from `<tmp>`.
   - `<old>` not in the history (`git -C <tmp> cat-file -e <old>^{commit}` fails, e.g. force-push) → report it; treat the whole folder as changed.
   - `git -C <tmp> ls-tree <new> -- <path>` is empty → report "removed or moved upstream" (common for paths like `in-progress/` or `experimental/`). Look for the new home: `git -C <tmp> ls-tree -r --name-only <new> | grep '/<folder name>/SKILL.md$'`, and list any hits as candidate paths. Tell the user to re-search the correct location (a hit, a renamed folder, or another repo); the user picks a new path (then update `metadata.source.path` and rerun this item), keeps the local copy unchanged, or drops it. Next item.
3. `git -C <tmp> diff --quiet <old> <new> -- <path>` succeeds → the folder is unchanged. Offer to record `<new>` as the commit (the user decides) and go to the next item.
4. Changed → stage it as an untrusted update:
   - extract the new folder: `git -C <tmp> archive <new> <path> | tar -x -C <tmp2>`, then copy it to `agent/skills-alchemy/data/<local skill folder name>/`. Already exists → ask (replace / skip);
   - write the upstream delta there: `git -C <tmp> diff <old> <new> -- <path> > …/.upstream.diff`. This file is untrusted: only the reviewer reads it;
   - write `.source.json`: `{"repo", "path", "commit": "<new>", "license": "<spdx now, as in add.md step 4>", "fetched": "<today>", "updates": "<local skill dir>", "previous": "<old>", "previous_description": "<description from `git -C <tmp> show <old>:<path>/SKILL.md`>"}`;
   - license differs from the recorded one → red flag in the report.
5. Delete the temp dirs.

Then list the results (up to date / unchanged folder / changed / removed) and run [inbox.md](inbox.md) for the staged updates. Update items (`.source.json` has `updates`) follow these rules there:
- S3 compares against the local skill named in `updates`; the same name is expected, not a clash. Report what upstream changed (from the reviewer's diff summary) and whether it touches lines the user edited locally.
- S5 offers per update item: **replace** (upstream version over the local one) / **merge** (apply only the upstream delta onto the local version, via the merge loop) / **skip** (nothing changes; delete the staged item). Replace and merge keep the local `metadata.skill-alchemy`; S3 checks the new sizes against it.
- Description: compare the filed description with `previous_description` in `python3 -I`, printing only same/different. Different → the user edited it; keep the local description on replace and merge by default, show both in the report, and run S3b on the new upstream one only if the user asks.
- S6 writes `metadata.source.commit` = `<new>`, `license`, `checked` into the resulting SKILL.md, keeps only `source` and `skill-alchemy` in its `metadata`, and leaves `.source.json` and `.upstream.diff` out.
