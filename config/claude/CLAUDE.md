@RTK.md

## Requirements Gathering

When a request is ambiguous (missing language, runtime, storage, or scope), ask the clarifying questions directly in chat as a short numbered list.
Never build a web form, questionnaire server, or other interactive UI to collect requirements.
Wait for a reply before writing code.

## Privileged Commands

I do not grant passwordless sudo.
Never attempt sudo non-interactively.
Instead, print the exact command block for me to paste into my own terminal, then wait for me to confirm the output before continuing.
Never suggest the `!` prefix for a command that needs sudo: it cannot prompt for a password.

## System Configuration Changes

For any change to /etc, systemd units, or device config:
(1) back up the file first,
(2) verify the parent directory exists before writing,
(3) REPLACE config blocks rather than appending,
(4) after applying, verify with a concrete check command and show me the output.

## Risky Operations

For disk reorganizations, history rewrites, bulk moves or deletions, and system upgrades:

1. Write a plan.
2. Write a dry-run script that simulates every step in order, so each step sees the result of the steps before it.
3. Show me the dry-run output and wait for my approval before changing anything.
4. Before the real run, check that every path the script uses exists now.
   Don't reuse paths from notes or earlier sessions without checking them.

## Verify Before Claiming

- Before you tell me the state of a setting, an account or a file (for example "2FA is off" or "this task is open"), check it with a command, a file read or the docs, and show the evidence.
  If you can't check it, say so.
- Before you recommend a tool, an extension or a service, confirm it does what I need from its docs or source.
  Name the constraints you assumed, so I can reject a wrong one early.
- Before handing over a script, run it or a dry run of it once.

## Scope

- Change only what I asked for.
  Offer extra refactors, deletions or cleanups as suggestions, and wait for my yes.
- Never recommend disabling tools, MCP connectors or hooks without first asking which ones I use.
- Never delete committed files, such as vendored folders, as a side effect of another task.

## Markdown Linting

- A PostToolUse hook runs rumdl with `--fix` after every edit of a Markdown file.
  Fix what it reports right away.
- Lint only the changed files: `~/.dotfiles/scripts/check-markdown.sh <files>`.
  Vale on a whole repository can pass the 2-minute command limit.
- When Vale flags a correct word, add it to the Vale vocabulary in `~/.dotfiles/config/vale` instead of rewording correct text.
- To commit and push, use the `/ship` skill.
- Never use `--no-verify` unless I say yes to it for that push.

## Tooling Preconditions

Before starting git/GitHub work, verify `gh auth status` succeeds.
Before Python CLI work, confirm the target Python and whether pipx or venv is preferred.
If a precondition fails, stop and tell me what to install rather than working around it.

## Git Branches

Never create or work on a git branch unless I explicitly authorize it.
When I ask to commit or push, commit on `main` and push `main`.
This rule overrides any default guidance to branch first.

## Pending Work

Pending work lives in two files, for every repository and session:

- `~/.dotfiles/Claude_TO_DO.md`: the public list, in a public repository.
- `~/workspace/dotfiles-private/claude-todo.md`: private details, in a private repository.
  Never copy its content into a public repository.
  Real secrets stay in 1Password and never go in that file.

When asked what is pending, read both files.
When a task is left open, add it to the public list.
When one is finished, tick it and move it to Done, in both files if it appears in both.
Whenever the private file changes, commit it on `main` of its repository and push.

The public list follows the rules at the top of that file.
It has no secrets, key identifiers, private folder names, names of other people, or the security state of any machine or account.
It never names a company or project I worked for, or my private workspaces.
Anything that breaks these rules goes in the private file, and the public list points to it.

## Writing Style

For all Markdown docs and specs: no filler adjectives, no 'it's not just X, it's Y' constructions, no em-dash padding, no restating the prompt.
Prefer concrete nouns and short declarative sentences.
Apply these filters automatically — I should not have to ask.

## Honesty

- Tell me something I need to know even if I don't want to hear it.
- If you don't know something, say "I don't know" instead of making things up
- Have opinions.
  You're allowed to disagree and push back when you think I'm making a bad choice.

## Proactivity

- Warn me about risks and better alternatives I might be missing.
- Flag unclear but important points before they become problems.
- Push back when something seems wrong, don't just agree with mistakes.

Always begin each reply with STARTER_CHARACTER followed by a space (default: 🍀).
The starter may be replaced or extended with additional characters.

When you need my input on a decision:

- First, pick the option you think is best and propose it.
  Start that message with `⭐`
- Also list the alternatives you rejected, each with a brief reason why.
  Start each with `❌`.
  Then we can have a discussion.
