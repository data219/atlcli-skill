# atlcli agent skill

This repository contains an agent skill for working with Atlassian Jira and
Confluence through [`atlcli`](https://atlcli.sh/).

Use it when you want a coding agent to use `atlcli` from the terminal for work
such as:

- finding Jira issues, boards, sprints, and worklogs
- reading or syncing Confluence pages
- adding or resolving Confluence comments
- turning `atlcli --json` output into Markdown links
- checking local `atlcli` help before running a command

The skill does not install `atlcli`. Install and configure the CLI first. This
skill tells the agent how to use it with a read-first workflow and extra care
around Jira or Confluence changes.

## What's included

- `SKILL.md`: the agent instructions.
- `COMMAND-REFERENCE.md`: a bundled command map for discovery.
- `scripts/atl_md_links.sh`: renders Atlassian JSON objects as Markdown links.
- `scripts/safe_wiki_sync.sh`: guarded Confluence docs sync flow.
- `scripts/verify_skill_evidence.sh`: checks that the skill files and bundled
  command notes still match the expected evidence before release.
- `scripts/extract_doc_commands.py`: helper for refreshing command references
  from the public docs.
- `agents/openai.yaml`: companion agent configuration.

## When to use it

Use this skill when an agent needs to operate Jira or Confluence through
`atlcli`, especially if the task includes writes. It is also useful when the
agent needs to route between Jira and Confluence command groups or inspect JSON
output before deciding what to do next.

Skip it for general Atlassian product advice that does not involve the local
CLI, or when `atlcli` is not installed and the task is only about planning.

## Safety model

For read-only work, the agent can inspect data with `atlcli --json` and
summarize the result.

For writes, the skill requires a read-first workflow:

1. Preview with `get`, `list`, `search`, `status`, `diff`, `check --strict`, or
   an equivalent read command.
2. Use a tight scope: issue key, page ID, comment ID, sprint ID, project key, or
   a narrow query.
3. Use `--profile <name>` explicitly.
4. Ask for confirmation before high-impact actions such as delete, bulk, push,
   resolve, update, import, export, install, enable, disable, login, or logout.
5. Verify the result with a read command and report the URL or ID.

The local CLI help wins. If `atlcli --help` or `atlcli <group> --help` disagrees
with `COMMAND-REFERENCE.md`, use the local help output. Stop before any mutation
when the difference affects scope, flags, authentication, or safety.

Do not write or print secrets. Treat `config list`, logs, tokens, and profile
data as sensitive unless the user explicitly says otherwise.

## Manual installation

### Codex or shared agent skills

Use this when your agent reads skills from `~/.agents/skills`.

```bash
ATLCLI_SKILL_REPO="https://github.com/data219/atlcli-skill.git"
ATLCLI_SKILL_DIR="$HOME/.agents/external-skills/atlcli-skill"
ATLCLI_SKILL_LINK="$HOME/.agents/skills/atlcli"

mkdir -p "$HOME/.agents/external-skills" "$(dirname "$ATLCLI_SKILL_LINK")"
if [ -d "$ATLCLI_SKILL_DIR/.git" ]; then
    git -C "$ATLCLI_SKILL_DIR" pull --ff-only
else
    git clone "$ATLCLI_SKILL_REPO" "$ATLCLI_SKILL_DIR"
fi
if [ -e "$ATLCLI_SKILL_LINK" ] || [ -L "$ATLCLI_SKILL_LINK" ]; then
    rm -rf "$ATLCLI_SKILL_LINK"
fi
ln -s "$ATLCLI_SKILL_DIR" "$ATLCLI_SKILL_LINK"
test -f "$ATLCLI_SKILL_LINK/SKILL.md"
```

### Claude Code

If your Claude Code setup reads `~/.claude/skills`, install the skill there:

```bash
ATLCLI_SKILL_REPO="https://github.com/data219/atlcli-skill.git"
ATLCLI_SKILL_DIR="$HOME/.agents/external-skills/atlcli-skill"
ATLCLI_SKILL_LINK="$HOME/.claude/skills/atlcli"

mkdir -p "$HOME/.agents/external-skills" "$(dirname "$ATLCLI_SKILL_LINK")"
if [ -d "$ATLCLI_SKILL_DIR/.git" ]; then
    git -C "$ATLCLI_SKILL_DIR" pull --ff-only
else
    git clone "$ATLCLI_SKILL_REPO" "$ATLCLI_SKILL_DIR"
fi
if [ -e "$ATLCLI_SKILL_LINK" ] || [ -L "$ATLCLI_SKILL_LINK" ]; then
    rm -rf "$ATLCLI_SKILL_LINK"
fi
ln -s "$ATLCLI_SKILL_DIR" "$ATLCLI_SKILL_LINK"
test -f "$ATLCLI_SKILL_LINK/SKILL.md"
```

If your machine already links `~/.claude/skills` to `~/.agents/skills`, use the
Codex/shared install instead.

### Cline, Roo, Continue, and other local agents

Agents differ here. Use the skill directory your agent reads for local
`SKILL.md` files, then symlink or copy this checkout as `atlcli`.

```bash
ATLCLI_SKILL_REPO="https://github.com/data219/atlcli-skill.git"
ATLCLI_SKILL_DIR="$HOME/.agents/external-skills/atlcli-skill"
AGENT_SKILLS_DIR="${AGENT_SKILLS_DIR:-$HOME/.agents/skills}"
ATLCLI_SKILL_LINK="$AGENT_SKILLS_DIR/atlcli"

mkdir -p "$HOME/.agents/external-skills" "$AGENT_SKILLS_DIR"
if [ -d "$ATLCLI_SKILL_DIR/.git" ]; then
    git -C "$ATLCLI_SKILL_DIR" pull --ff-only
else
    git clone "$ATLCLI_SKILL_REPO" "$ATLCLI_SKILL_DIR"
fi
if [ -e "$ATLCLI_SKILL_LINK" ] || [ -L "$ATLCLI_SKILL_LINK" ]; then
    rm -rf "$ATLCLI_SKILL_LINK"
fi
ln -s "$ATLCLI_SKILL_DIR" "$ATLCLI_SKILL_LINK"
test -f "$ATLCLI_SKILL_LINK/SKILL.md"
```

If your agent has no skill directory but can read repository instructions, add
this repository as a subdirectory or reference it from your agent instructions.

## Ask an agent to install it

### Codex prompt

```text
Install the public atlcli agent skill for Codex.

Use https://github.com/data219/atlcli-skill.git as the source. Clone or update it under ~/.agents/external-skills/atlcli-skill, then expose it as ~/.agents/skills/atlcli with a symlink. Do not write or print secrets. After installation, verify that ~/.agents/skills/atlcli/SKILL.md exists. If atlcli is installed, also run atlcli --version and atlcli --help and summarize the result.
```

### Claude Code prompt

```text
Install the public atlcli agent skill for Claude Code.

Use https://github.com/data219/atlcli-skill.git as the source. If ~/.claude/skills is a real skills directory, expose the checkout as ~/.claude/skills/atlcli. If ~/.claude/skills points to ~/.agents/skills, install it through ~/.agents/skills/atlcli instead. Do not write or print secrets. Verify that the final atlcli/SKILL.md file exists. If atlcli is installed, run atlcli --version and atlcli --help and summarize the result.
```

### Cline/Roo-style prompt

```text
Install the public atlcli agent skill for this local agent setup.

Use https://github.com/data219/atlcli-skill.git as the source. Find the local skill directory this agent reads for SKILL.md-based skills. Clone or update the repository under a stable external-skills directory, then symlink or copy it as atlcli into the agent's skills directory. Do not write or print secrets. Verify that the agent-visible atlcli/SKILL.md exists. If atlcli is installed, run atlcli --version and atlcli --help and summarize the result.
```

### Current repository prompt

```text
Install the public atlcli agent skill for this repository.

Use https://github.com/data219/atlcli-skill.git as the source. Put the checkout in a stable local or user-level external-skills directory, then make the skill visible from this repository's agent skill directory as atlcli. Do not write or print secrets. Verify that atlcli/SKILL.md is visible from the final skill path. If atlcli is installed, run atlcli --version and atlcli --help and summarize the result.
```

## Quick checks

```bash
test -f ~/.agents/skills/atlcli/SKILL.md
atlcli --version
atlcli --help
```

If `atlcli` is missing, install and configure it from the official project
documentation before asking the agent to perform Jira or Confluence work.
