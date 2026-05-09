#!/bin/bash
# Hoardseeker test runner wrapper (Git Bash / WSL / Linux / macOS).
#
# Run with: bash tests/run.sh   (from inside the hoardseeker/ directory)
#
# Why this exists:
#   On a fresh checkout (no .godot/ cache yet), running test_runner.gd directly
#   produces "Could not resolve external class member" parse errors for any
#   test that references cross-class typed @exports (e.g. GameState's
#   Array[PlayerState]). The class registry hasn't been built yet.
#
#   This wrapper runs --import once first to build the registry, then runs
#   the test runner. CI does the same; this gives local devs the same
#   guarantee.
#
# See TECH_DEBT.md ("Local tests require godot --headless --import on fresh
# checkout") for full background.

set -e

# Run from the directory containing project.godot regardless of where the
# user invoked the script from.
cd "$(dirname "$0")/.."

echo "================================================================"
echo " Importing project (builds class registry)..."
echo "================================================================"
# --import can exit non-zero on first run for non-fatal reasons (warnings,
# missing imported resources). The test step is the real signal.
godot --headless --import 2>&1 | tail -20 || true
echo ""

echo "================================================================"
echo " Running headless tests..."
echo "================================================================"
exec godot --headless --script tests/test_runner.gd
