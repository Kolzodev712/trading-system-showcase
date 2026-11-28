#!/usr/bin/env bash
# PREPARE ONLY — do not run until the owner approves.
# Creates shared labels across the four public repos (idempotent-ish: create may fail if exists).
set -euo pipefail

REPOS=(
  Kolzodev712/trading_system
  Kolzodev712/k-paper
  Kolzodev712/trading-system-ui
  Kolzodev712/trading-system-showcase
)

create_label() {
  local repo=$1 name=$2 color=$3 desc=$4
  gh label create "$name" -R "$repo" --color "$color" --description "$desc" 2>/dev/null \
    || gh label edit "$name" -R "$repo" --color "$color" --description "$desc"
}

for repo in "${REPOS[@]}"; do
  echo "== $repo =="
  create_label "$repo" "testing" "BFD4F2" "Verification and test coverage"
  create_label "$repo" "needs-design" "D4C5F9" "Requires architectural discussion"
  create_label "$repo" "needs-reproduction" "FEF2C0" "Insufficient evidence to establish a defect"
  create_label "$repo" "difficulty: easy" "C2E0C6" "Beginner-friendly scope"
  create_label "$repo" "difficulty: medium" "FEF2C0" "Moderate complexity"
  create_label "$repo" "difficulty: hard" "F9D0C4" "Advanced / high scrutiny"
  create_label "$repo" "priority: high" "B60205" "High priority"
  create_label "$repo" "priority: medium" "FBCA04" "Medium priority"
  create_label "$repo" "priority: low" "0E8A16" "Low priority"
done

echo "Standard labels (bug, enhancement, documentation, good first issue, help wanted) already exist on GitHub defaults."
