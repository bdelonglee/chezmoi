#!/usr/bin/env bash
# Finds every repo chezmoi auto-clones via a run_once_after_*.sh script
# (parsed from their target="..." line), and checks each is pushed to
# origin. Prompts to push anything that isn't, so a fresh `chezmoi apply`
# on a new machine never clones a repo that's missing local-only work.

set -euo pipefail

if [[ -t 1 ]]; then
    bold=$'\033[1m'
    dim=$'\033[2m'
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    blue=$'\033[34m'
    reset=$'\033[0m'
else
    bold="" dim="" red="" green="" yellow="" blue="" reset=""
fi

status_label() {
    case "$1" in
        '??') echo "new" ;;
        ' M'|'M '|'MM') echo "modified" ;;
        ' D'|'D ') echo "deleted" ;;
        ' A'|'A ') echo "added" ;;
        R*) echo "renamed" ;;
        *) echo "$1" ;;
    esac
}

source_dir=$(chezmoi source-path)

targets=()
while IFS= read -r line; do
    targets+=("$line")
done < <(
    grep -h '^target=' "$source_dir"/run_once_after_*.sh 2>/dev/null \
        | sed -E 's/^target="?(.*[^"])"?$/\1/' \
        | while read -r t; do eval echo "$t"; done
)

if [[ ${#targets[@]} -eq 0 ]]; then
    echo "No run_once_after_*.sh clone targets found."
    exit 0
fi

echo "${bold}Checking ${#targets[@]} chezmoi-cloned repos…${reset}"
echo

needs_attention=()

for dir in "${targets[@]}"; do
    name=$(basename "$dir")
    printf '%s%s%s  %s%s%s\n' "$bold" "$name" "$reset" "$dim" "$dir" "$reset"

    if [[ ! -d "$dir/.git" ]]; then
        printf '   %s○ not present locally, skipping%s\n\n' "$dim" "$reset"
        continue
    fi

    dirty=""
    porcelain="$(git -C "$dir" status --porcelain)"
    if [[ -n "$porcelain" ]]; then
        dirty="1"
        printf '   %s⚠ uncommitted changes%s %s(not pushable as-is)%s\n' "$yellow" "$reset" "$dim" "$reset"
        while IFS= read -r entry; do
            code="${entry:0:2}"
            file="${entry:3}"
            printf '     %s%-8s%s %s\n' "$dim" "$(status_label "$code")" "$reset" "$file"
        done <<< "$porcelain"
    fi

    branch=$(git -C "$dir" branch --show-current)
    git -C "$dir" fetch origin --quiet 2>/dev/null || true

    if ! git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
        printf '   %s✗ branch %s%s%s has no upstream tracking on origin%s\n' "$red" "$bold" "$branch" "$red" "$reset"
        needs_attention+=("$name")
        read -r -p "   push and set upstream now? [y/N] " ans
        echo
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            git -C "$dir" push -u origin "$branch"
            echo
        fi
        continue
    fi

    ahead=$(git -C "$dir" rev-list --count '@{u}..HEAD')
    if [[ "$ahead" -gt 0 ]]; then
        printf '   %s✗ %s commit(s) ahead of origin/%s%s\n' "$red" "$ahead" "$branch" "$reset"
        needs_attention+=("$name")
        read -r -p "   push now? [y/N] " ans
        echo
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            git -C "$dir" push origin "$branch"
            echo
        fi
    else
        printf '   %s✓ up to date with origin/%s%s\n\n' "$green" "$branch" "$reset"
        [[ -n "$dirty" ]] && needs_attention+=("$name")
    fi
done

if [[ ${#needs_attention[@]} -eq 0 ]]; then
    echo "${green}${bold}All clean — everything pushed.${reset}"
else
    echo "${yellow}${bold}Needs attention:${reset} ${needs_attention[*]}"
fi
