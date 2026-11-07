---
name: ship
description: Lint, commit and push the pending changes of the current repository on main. Use when the user says ship, commit and push, or commit this.
---

# Ship

Lint the changed Markdown, commit on `main` and push.
Follow the steps in order.
Stop and report when a step fails and the cause is unclear.

## 1. Check the state

- Run `gh auth status`.
  If it fails, stop and tell the user to log in.
- Run `git status --short` and `git branch --show-current`.
- The branch must be `main`.
  On any other branch, stop and ask.
- List the changed and untracked files.
  Ignore `.venv`, `node_modules` and build output.

## 2. Check what goes public

Run `gh repo view --json visibility -q .visibility`.
If the repository is public, read the full diff before committing.
Look for personal details, hostnames, backup locations, private folder names, names of other people, company or project names, credentials and key identifiers.
If you find any, stop and report them with file and line.
They belong in the private repository, not in a public commit.

## 3. Lint the changed Markdown

Run the shared checker only on the changed Markdown files:

```bash
git diff --name-only --diff-filter=ACMRT HEAD -- '*.md' '*.markdown' \
  | xargs -r ~/.dotfiles/scripts/check-markdown.sh
```

Also pass the untracked Markdown files you will commit.
Never run it without paths in a large repository: Vale on every file can pass the 2-minute command limit.
If the list is long, run it with `run_in_background`.

Then fix the results:

- Fix every rumdl issue that `--fix` left.
  Wrap lines over 200 characters at sentence boundaries.
- Fix broken relative links and image paths.
- Fix Vale errors.
  When Vale flags a correct word (a proper noun, a tool name, a Spanish word), add it to `~/.dotfiles/config/vale/styles/config/vocabularies/Dotfiles/accept.txt`.
  Don't reword correct text.
  That file is in the public dotfiles repository, so commit it there.
- Leave write-good warnings you disagree with, and list them in the report.
- Change nothing beyond what the fixes need.

Rerun the checker until rumdl reports no issues.

## 4. Update pending work

If the work closes a task in `~/.dotfiles/Claude_TO_DO.md` or `~/workspace/dotfiles-private/claude-todo.md`, tick it and move it to Done in each file where it appears.
Read both files from disk first.
Don't rely on what you remember from earlier in the session.
If you changed the private file, commit it on `main` of its repository and push.

## 5. Commit

- Stage the files by name.
  Don't use `git add -A`.
- Group the changes into one commit per topic.
- Write a short imperative subject line.
  End the message with the attribution lines the session requires.

## 6. Push

Run `git push origin main`.
If a pre-commit or pre-push hook fails:

1. Read its output and find the cause.
2. Fix the cause and retry, up to 3 times.
3. If it still fails, stop and report the cause.

Never use `--no-verify` unless the user says yes to it for this push.

## 7. Report

Finish with a table: file, issues fixed, vocabulary added, warnings left.
Then list the commit SHAs and the push result.
