#!/usr/bin/env bash
#
# Myskills installer
#
#   curl -fsSL https://raw.githubusercontent.com/K-arch-droid/Myskills/main/scripts/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --agent qoder --global
#   curl -fsSL .../install.sh | bash -s -- --list
#
# Can also be run from a local clone: bash scripts/install.sh --agent codex

set -uo pipefail

REPO="${REPO:-K-arch-droid/Myskills}"
BRANCH="${BRANCH:-main}"

AGENT=""
SCOPE="auto"
SKILL_FILTER=""
LIST_ONLY=0
DRY_RUN=0
FORCE=0

usage() {
  cat <<'EOF'
Myskills installer

Usage:
  install.sh [options]

Options:
  -a, --agent <name>    Target agent:
                        qoder qoderwork claude codex cursor opencode qwen
                        windsurf trae roo kiro agents
  -g, --global          Install to user-level directory
  -p, --project         Install to project-level directory
  -s, --skill <names>   Comma-separated skill names (default: all)
  -l, --list            List available skills and exit
  -n, --dry-run         Show what would happen
  -f, --force           Overwrite existing skill directories
  -h, --help            Show this help

Environment:
  REPO=<owner/repo>     Default: K-arch-droid/Myskills
  BRANCH=<branch>       Default: main
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -a|--agent)    AGENT="${2:-}"; shift 2 ;;
    -g|--global)   SCOPE="global"; shift ;;
    -p|--project)  SCOPE="project"; shift ;;
    -s|--skill)    SKILL_FILTER="${2:-}"; shift 2 ;;
    -l|--list)     LIST_ONLY=1; shift ;;
    -n|--dry-run)  DRY_RUN=1; shift ;;
    -f|--force)    FORCE=1; shift ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

global_dir_for() {
  case "$1" in
    qoder)             echo "$HOME/.qoder/skills" ;;
    qoderwork)         echo "$HOME/.qoderwork/skills" ;;
    claude|claude-code) echo "$HOME/.claude/skills" ;;
    codex)             echo "$HOME/.codex/skills" ;;
    cursor)            echo "$HOME/.cursor/skills" ;;
    opencode)          echo "$HOME/.config/opencode/skills" ;;
    qwen|qwencode)     echo "$HOME/.qwen/skills" ;;
    windsurf)          echo "$HOME/.codeium/windsurf/skills" ;;
    trae)              echo "$HOME/.trae/skills" ;;
    roo)               echo "$HOME/.roo/skills" ;;
    kiro)              echo "$HOME/.kiro/skills" ;;
    agents)            echo "$HOME/.agents/skills" ;;
    *) return 1 ;;
  esac
}

project_dir_for() {
  case "$1" in
    qoder|qoderwork)    echo ".qoder/skills" ;;
    claude|claude-code) echo ".claude/skills" ;;
    codex)              echo ".codex/skills" ;;
    cursor)             echo ".cursor/skills" ;;
    opencode)           echo ".opencode/skills" ;;
    qwen|qwencode)      echo ".qwen/skills" ;;
    windsurf)           echo ".windsurf/skills" ;;
    trae)               echo ".trae/skills" ;;
    roo)                echo ".roo/skills" ;;
    kiro)               echo ".kiro/skills" ;;
    agents)             echo ".agents/skills" ;;
    *) return 1 ;;
  esac
}

# ---------------------------------------------------------------- source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SRC=""

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../skills" ]; then
  SRC="$SCRIPT_DIR/../skills"
else
  TMP="$(mktemp -d 2>/dev/null || echo "/tmp/myskills.$$")"
  trap 'rm -rf "$TMP"' EXIT

  echo "Downloading ${REPO}@${BRANCH} ..." >&2
  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TMP/repo" >/dev/null 2>&1
    SRC="$TMP/repo/skills"
  elif command -v curl >/dev/null 2>&1; then
    mkdir -p "$TMP"
    curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" \
      | tar -xz -C "$TMP" 2>/dev/null
    SRC="$TMP/${REPO#*/}-${BRANCH}/skills"
  else
    echo "Error: need git or curl to download." >&2
    exit 1
  fi
fi

if [ ! -d "$SRC" ]; then
  echo "Error: skills directory not found at $SRC" >&2
  exit 1
fi

# ---------------------------------------------------------------- discover
ALL_SKILLS=()
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  [ -f "${d}SKILL.md" ] || continue
  ALL_SKILLS+=("$(basename "$d")")
done

if [ ${#ALL_SKILLS[@]} -eq 0 ]; then
  echo "Error: no skills found under $SRC" >&2
  exit 1
fi

if [ "$LIST_ONLY" -eq 1 ]; then
  echo "Available skills in ${REPO}:"
  for s in "${ALL_SKILLS[@]}"; do
    desc="$(awk '/^---[[:space:]]*$/{f++; next} f==1 && /^description:/{sub(/^description:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$SRC/$s/SKILL.md")"
    printf '  %-22s %s\n' "$s" "$desc"
  done
  exit 0
fi

# ---------------------------------------------------------------- target
if [ -z "$AGENT" ]; then
  # auto-detect: prefer an agent whose global dir already exists
  for a in qoder qoderwork claude codex cursor opencode qwen windsurf trae roo kiro agents; do
    d="$(global_dir_for "$a")"
    if [ -d "$d" ]; then AGENT="$a"; break; fi
  done
fi

if [ -z "$AGENT" ]; then
  echo "Could not detect an installed agent. Re-run with: --agent <name>" >&2
  echo "Detected no existing skills directory in \$HOME." >&2
  exit 1
fi

if ! global_dir_for "$AGENT" >/dev/null 2>&1; then
  echo "Unknown agent: $AGENT" >&2
  usage
  exit 1
fi

if [ "$SCOPE" = "auto" ]; then
  g="$(global_dir_for "$AGENT")"
  p="$(project_dir_for "$AGENT")"
  if [ -d "$g" ] && [ -d "$p" ]; then
    echo "Both user-level and project-level directories exist." >&2
    echo "  user:    $g" >&2
    echo "  project: $p" >&2
    printf 'Install to? [user/project] ' >&2
    read -r ans || ans=""
    case "$ans" in
      p*|P*) SCOPE="project" ;;
      *)    SCOPE="global" ;;
    esac
  elif [ -d "$g" ]; then
    SCOPE="global"
  elif [ -d "$p" ]; then
    SCOPE="project"
  else
    SCOPE="global"
  fi
fi

if [ "$SCOPE" = "global" ]; then
  DEST="$(global_dir_for "$AGENT")"
else
  DEST="$(project_dir_for "$AGENT")"
fi

# ---------------------------------------------------------------- install
if [ -n "$SKILL_FILTER" ]; then
  IFS=',' read -r -a WANTED <<< "$SKILL_FILTER"
else
  WANTED=("${ALL_SKILLS[@]}")
fi

echo "Agent:  $AGENT"
echo "Scope:  $SCOPE"
echo "Target: $DEST"
echo "Skills: ${WANTED[*]}"
echo

installed=0
skipped=0
failed=0

for s in "${WANTED[@]}"; do
  s="$(echo "$s" | tr -d '[:space:]')"
  [ -z "$s" ] && continue

  if [ ! -d "$SRC/$s" ]; then
    echo "  SKIP  $s (not found in repository)"
    failed=$((failed + 1))
    continue
  fi

  if [ -d "$DEST/$s" ] && [ "$FORCE" -ne 1 ]; then
    echo "  SKIP  $s (already exists at $DEST/$s, use --force to overwrite)"
    skipped=$((skipped + 1))
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  PLAN  $s -> $DEST/$s"
    installed=$((installed + 1))
    continue
  fi

  mkdir -p "$DEST/$s"
  if cp -R "$SRC/$s/." "$DEST/$s/" 2>/dev/null; then
    if [ -f "$DEST/$s/SKILL.md" ]; then
      echo "  OK    $s -> $DEST/$s"
      installed=$((installed + 1))
    else
      echo "  FAIL  $s (SKILL.md missing after copy)"
      failed=$((failed + 1))
    fi
  else
    echo "  FAIL  $s (copy error)"
    failed=$((failed + 1))
  fi
done

echo
echo "Installed: $installed   Skipped: $skipped   Failed: $failed"

if [ "$installed" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  echo
  echo "Restart your agent to load the new skills."
fi

[ "$failed" -eq 0 ]
