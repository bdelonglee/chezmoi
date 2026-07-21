#!/usr/bin/env bash
# Finds every repo chezmoi auto-clones via a run_once_after_*.sh script
# (parsed from their target="..." line), and checks each is pushed to
# origin. Prompts to push anything that isn't, so a fresh `chezmoi apply`
# on a new machine never clones a repo that's missing local-only work.

set -euo pipefail

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

for dir in "${targets[@]}"; do
    echo "== $dir =="

    if [[ ! -d "$dir/.git" ]]; then
        echo "  not present locally, skipping"
        continue
    fi

    if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
        echo "  uncommitted changes present (not pushable as-is)"
    fi

    branch=$(git -C "$dir" branch --show-current)
    git -C "$dir" fetch origin --quiet 2>/dev/null || true

    if ! git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
        echo "  branch '$branch' has no upstream tracking on origin"
        read -r -p "  push and set upstream now? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            git -C "$dir" push -u origin "$branch"
        fi
        continue
    fi

    ahead=$(git -C "$dir" rev-list --count '@{u}..HEAD')
    if [[ "$ahead" -gt 0 ]]; then
        echo "  $ahead commit(s) ahead of origin/$branch"
        read -r -p "  push now? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            git -C "$dir" push origin "$branch"
        fi
    else
        echo "  up to date with origin/$branch"
    fi
done
