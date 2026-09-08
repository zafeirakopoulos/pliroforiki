#!/usr/bin/env bash
# Build the interactive notes and publish them to GitHub Pages.
#
# Repo layout (github.com/zafeirakopoulos/pliroforiki):
#   main      -> these .qmd sources  (this directory is its checkout)
#   gh-pages  -> the rendered HTML    (the pliroforiki/ subdir is its checkout)
#
#   ./deploy.sh          # render + sync the HTML into pliroforiki/
#   then:  cd pliroforiki && git add -A && git commit -m 'render' && git push
#   (and, separately, commit + push source changes from this directory to main)
set -euo pipefail
cd "$(dirname "$0")"

quarto render

# Quarto's resource scanner sees that pliroforiki/*.html reference uoa-logo.svg
# and copies it to _site/pliroforiki/ -- a self-referential artifact, drop it.
rm -rf _site/pliroforiki

# Mirror _site -> pliroforiki/ (the gh-pages checkout), preserving its .git
find pliroforiki -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -a _site/. pliroforiki/
rm -rf pliroforiki/pliroforiki   # belt and braces

echo
echo "Synced _site/ -> pliroforiki/  (branch: $(git -C pliroforiki branch --show-current))"
echo "Next:  cd pliroforiki && git add -A && git commit -m render && git push"
