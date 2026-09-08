#!/usr/bin/env bash
# Build the interactive notes and publish them to the `pliroforiki` deploy repo
# (github.com/zafeirakopoulos/pliroforiki -> GitHub Pages).
#
#   ./deploy.sh            # render + sync into pliroforiki/
#   then:  cd pliroforiki && git add -A && git commit && git push
set -euo pipefail
cd "$(dirname "$0")"

quarto render

# The deploy repo lives inside this project dir (pliroforiki/). Quarto's resource
# scanner notices that pliroforiki/*.html reference uoa-logo.svg and copies it to
# _site/pliroforiki/ -- a self-referential artifact we never want in the build.
rm -rf _site/pliroforiki

# Mirror _site -> pliroforiki/, preserving that repo's .git
find pliroforiki -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -a _site/. pliroforiki/
rm -rf pliroforiki/pliroforiki   # belt and braces

echo
echo "Synced _site/ -> pliroforiki/"
echo "Next:  cd pliroforiki && git add -A && git commit && git push"
