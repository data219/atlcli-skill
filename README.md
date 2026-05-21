# atlcli agent skill

[![Skill](https://img.shields.io/badge/agent%20skill-atlcli-blue?style=flat-square)](SKILL.md)
[![Atlassian CLI](https://img.shields.io/badge/atlcli-Jira%20%2B%20Confluence-0052CC?style=flat-square)](https://atlcli.sh/)
[![Install source](https://img.shields.io/badge/install-archive-24292f?style=flat-square&logo=github)](https://github.com/data219/atlcli-skill)

Agent instructions for working with Atlassian Jira and Confluence through
[`atlcli`](https://atlcli.sh/). The skill gives coding agents a safer command
workflow: inspect first, scope tightly, use explicit profiles, confirm risky
changes, and verify after writes.

[What it does](#what-it-does) | [Install](#install) | [Ask an agent to install it](#ask-an-agent-to-install-it) | [Use it](#use-it) | [License](#license)

> [!IMPORTANT]
> This repository installs the agent skill, not the `atlcli` binary. Install
> and configure `atlcli` first.

## What it does

Use this skill when a coding agent needs to operate Jira or Confluence from the
terminal with `atlcli`.

It is useful for:

- finding Jira issues, boards, sprints, worklogs, and related pages
- reading Confluence pages, spaces, comments, and docs sync status
- adding or resolving Confluence inline comments
- running guarded Confluence docs sync flows

## What's included

| Path | Purpose |
| --- | --- |
| [`SKILL.md`](SKILL.md) | The instructions an agent should load before using `atlcli`. |
| [`COMMAND-REFERENCE.md`](COMMAND-REFERENCE.md) | Command map for discovery and routing. It is not the safety policy. |
| [`scripts/atl_md_links.sh`](scripts/atl_md_links.sh) | Converts Atlassian JSON output into Markdown links. |
| [`scripts/safe_wiki_sync.sh`](scripts/safe_wiki_sync.sh) | Pull, check, diff, and push flow for Confluence docs sync. |
| [`scripts/extract_doc_commands.py`](scripts/extract_doc_commands.py) | Helper for refreshing the bundled command reference. |

## Prerequisites

- [`atlcli`](https://atlcli.sh/) installed and configured with a profile
- An agent that can load local `SKILL.md`-style skill folders

Get `atlcli` from the [atlcli homepage](https://atlcli.sh/) or the
[BjoernSchotte/atlcli GitHub repository](https://github.com/BjoernSchotte/atlcli).

Quick CLI check:

```bash
atlcli --version
atlcli --help
```

## Install

Archive link:

```text
https://github.com/data219/atlcli-skill/archive/refs/heads/main.tar.gz
```

Download that archive with your browser or any tool you prefer. Then unpack it,
rename the extracted `atlcli-skill-main` folder to `atlcli`, and place it in the
skill directory your agent reads.

Common destinations:

| Agent | Personal install | Project install | Typical use |
| --- | --- | --- | --- |
| Codex | `~/.codex/skills/atlcli` or `~/.agents/skills/atlcli` | `.agents/skills/atlcli` | Automatic or `$atlcli` |
| Claude Code | `~/.claude/skills/atlcli` | `.claude/skills/atlcli` | Automatic or `/atlcli` |
| GitHub Copilot | `~/.copilot/skills/atlcli` or `~/.agents/skills/atlcli` | `.github/skills/atlcli`, `.claude/skills/atlcli`, or `.agents/skills/atlcli` | Automatic or `/atlcli` |
| Cline, Cursor, Gemini CLI, OpenCode, Warp | `~/.agents/skills/atlcli` | `.agents/skills/atlcli` | Automatic, slash command, or file reference depending on the client |
| Roo | `~/.roo/skills/atlcli` | `.roo/skills/atlcli` | Client-specific skill loading |
| Windsurf | `~/.windsurf/skills/atlcli` | `.windsurf/skills/atlcli` | Client-specific skill loading |

### Example shell install for Codex or shared agent skills

Use this when your agent reads skills from `~/.agents/skills`. For a
Codex-only personal install, use `~/.codex/skills/atlcli` instead.

Unpack the archive as:

```text
~/.agents/skills/atlcli
```

Example shell install:

```bash
mkdir -p ~/.agents/skills
rm -rf ~/.agents/skills/atlcli
curl -fsSL https://github.com/data219/atlcli-skill/archive/refs/heads/main.tar.gz \
    | tar -xz -C ~/.agents/skills
mv ~/.agents/skills/atlcli-skill-main ~/.agents/skills/atlcli
test -f ~/.agents/skills/atlcli/SKILL.md
```

If your agent has no skill directory but can read repository instructions, add
this repository as a subdirectory and point the agent at `SKILL.md`.

## Ask an agent to install it

```text
Install the atlcli agent skill from https://github.com/data219/atlcli-skill.

Install it system-wide unless I ask for a project-local install. Put the skill folder where this agent reads local skills, name the final folder atlcli, and verify that SKILL.md exists. Do not write or print secrets.
```

## Use it

Once installed, ask your agent to use the `atlcli` skill for Atlassian terminal
work. Good prompts name the skill, the profile, the target, and whether writes
are allowed.

### Codex

Codex can load the skill when your request matches its description. You can also
name the skill directly with `$atlcli`:

```text
$atlcli With profile work, list open Jira issues assigned to me and summarize blockers. Read-only only.
```

```text
$atlcli With profile work, inspect Confluence page 12345 and prepare an inline comment for the third occurrence of "release window". Do not post it until I approve.
```

### Claude Code

Claude Code discovers skills from paths such as
`~/.claude/skills/atlcli/SKILL.md` or `.claude/skills/atlcli/SKILL.md`. It can
load the skill automatically when your request matches the description:

```text
Use the atlcli skill. With profile work, list open Jira issues assigned to me and summarize blockers. Read-only only.
```

Or invoke it directly with the skill command:

```text
/atlcli With profile work, inspect Confluence page 12345 and prepare an inline comment for the third occurrence of "release window". Do not post it until I approve.
```

### Other local agents

GitHub Copilot can load a matching skill automatically. In Copilot CLI, you can
also name it with a slash command:

```text
Use the /atlcli skill. With profile work, inspect issue ABC-123 and summarize the next action. Read-only only.
```

For agents that expose skills as slash commands, use the skill name directly:

```text
/atlcli With profile work, search Jira for unresolved issues in project ABC created this week. Read-only only.
```

For agents without a dedicated skill syntax, reference the installed skill file
explicitly:

```text
Load and follow ~/.agents/skills/atlcli/SKILL.md. With profile work, search Jira for unresolved issues in project ABC created this week. Read-only only.
```

For repository-scoped skills:

```text
Load and follow ./.agents/skills/atlcli/SKILL.md. With profile work, run a Confluence docs status check for ./docs and show me the diff before any push.
```

Helper scripts can also be used directly:

```bash
SKILL_DIR="${SKILL_DIR:-$HOME/.agents/skills/atlcli}"
atlcli --profile work jira issue get ABC-123 --json | "$SKILL_DIR/scripts/atl_md_links.sh"
"$SKILL_DIR/scripts/safe_wiki_sync.sh" ./docs --profile work
```

## License

MIT. See [LICENSE](LICENSE).

Repository self-check:

```bash
./scripts/verify_skill_evidence.sh .
```
