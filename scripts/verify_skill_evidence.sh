#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

require_file() {
    local path="$1"

    [ -f "$ROOT/$path" ] || fail "missing required file: $path"
}

require_text() {
    local path="$1"
    local pattern="$2"
    local description="$3"

    grep -Eq -- "$pattern" "$ROOT/$path" || fail "$path missing $description"
}

require_absent_text() {
    local pattern="$1"
    local description="$2"

    if grep -RInE --exclude-dir=.git -- "$pattern" "$ROOT" >/dev/null; then
        fail "$description"
    fi
}

require_file "SKILL.md"
require_file "COMMAND-REFERENCE.md"
require_file "scripts/atl_md_links.sh"
require_file "scripts/safe_wiki_sync.sh"
require_file "scripts/extract_doc_commands.py"

personal_path_pattern='/home''/jan'
generated_evidence_pattern='artifacts''/'

require_absent_text "$personal_path_pattern" "personal absolute path reference found"
require_absent_text "$generated_evidence_pattern" "stale generated-evidence directory reference found"

require_text "SKILL.md" 'add-inline' "inline comment command guidance"
require_text "SKILL.md" '--match-index' "match-index guidance"
require_text "SKILL.md" 'explicit user ACK' "destructive action ACK rule"
require_text "SKILL.md" 'stop and ask for explicit risk acceptance' "risk acceptance rule"
require_text "SKILL.md" 'verify_skill_evidence\.sh \.' "local verification command"

require_text "COMMAND-REFERENCE.md" 'Snapshot CLI version: `atlcli v0\.14\.0`' "snapshot version"
require_text "COMMAND-REFERENCE.md" 'EVIDENCE_DIR="\$\(mktemp -d\)"' "temporary evidence directory"
require_text "COMMAND-REFERENCE.md" '\$HOME/\.agents/skills/atlcli' "portable skill path example"
require_text "COMMAND-REFERENCE.md" 'https://atlcli\.sh/reference/cli-commands/' "CLI source link"

printf 'PASS: skill repository structure and public references are coherent\n'
