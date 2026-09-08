# Πληροφορική Ι — interactive lecture notes

Course notes for **141. Πληροφορική Ι**, Department of Mathematics, National and
Kapodistrian University of Athens. Written in [Quarto](https://quarto.org) with
[quarto-live](https://github.com/r-wasm/quarto-live), so every Python example
runs in the reader's browser via Pyodide — no install, no server.

Published at <https://zafeirakopoulos.github.io/pliroforiki/>.

## Repository layout

Two branches, two different things:

| Branch | Holds | Checked out as |
| --- | --- | --- |
| `main` | the `.qmd` sources | the repository root |
| `gh-pages` | the rendered HTML | the `pliroforiki/` subdirectory |

Sources live at the root: `main.qmd`, `week1.qmd` … `week13.qmd` for the notes,
and `week1-slides.qmd` … `week13-slides.qmd` for the matching decks. Each file
carries its own `format:` block; `_quarto.yml` only wires up shared branding and
the output directory.

## Prerequisites

Two requirements are easy to get wrong, and neither fails with an obvious
message. Get both right before you try to render.

### 1. Quarto 1.8.25 specifically

Use the same version the published site was built with. Rendering with a
different version rewrites boilerplate across every generated page, turning a
one-line edit into a diff over the whole site.

Check what the live site currently uses:

```bash
curl -s https://zafeirakopoulos.github.io/pliroforiki/week1.html \
  | grep -o '<meta name="generator" content="[^"]*"'
```

On macOS, install from the tarball rather than the `.pkg` — same binary, but it
needs no administrator password and keeps versions side by side:

```bash
mkdir -p ~/.local/opt ~/.local/bin
curl -fsSL -o /tmp/quarto.tar.gz \
  https://github.com/quarto-dev/quarto-cli/releases/download/v1.8.25/quarto-1.8.25-macos.tar.gz
mkdir -p ~/.local/opt/quarto-1.8.25
tar xzf /tmp/quarto.tar.gz -C ~/.local/opt/quarto-1.8.25
ln -sf ~/.local/opt/quarto-1.8.25/bin/quarto ~/.local/bin/quarto
```

Make sure `~/.local/bin` is on your `PATH`.

### 2. A Jupyter kernel — even though nothing executes locally

This one is counter-intuitive. Every Python cell here is a `{pyodide}` cell that
runs in the *reader's browser*; there are no `{python}` cells and nothing is
executed at render time. Quarto nevertheless routes documents containing
`{pyodide}` cells through its Jupyter engine, so a missing kernel stops the
render dead:

```
Starting python3 kernel...
ModuleNotFoundError: No module named 'yaml'
```

Give it a kernel of its own, so nothing lands in your system Python:

```bash
python3 -m venv ~/.local/opt/quarto-venv
~/.local/opt/quarto-venv/bin/pip install jupyter pyyaml
```

Then point Quarto at it via `QUARTO_PYTHON` (see below).

R is **not** required, despite `quarto check` reporting it as missing.

## Building

```bash
export PATH="$HOME/.local/bin:$PATH"
export QUARTO_PYTHON="$HOME/.local/opt/quarto-venv/bin/python"

quarto render     # build everything into _site/
quarto preview    # serve with live reload while writing
```

## Publishing

`deploy.sh` renders the site and mirrors `_site/` into `pliroforiki/`, which must
be a checkout of `gh-pages`. On a fresh clone that directory does not exist yet —
create it once:

```bash
git worktree add pliroforiki gh-pages
```

Then, for each release:

```bash
./deploy.sh
cd pliroforiki && git add -A && git commit -m render && git push
cd .. && git push          # and push the sources to main
```

Sources and rendered output are pushed separately. Pushing only `main` leaves the
live site stale.

## Notes for contributors

**Renaming a heading changes its anchor.** Quarto derives section ids from
heading text, so retitling a section silently breaks any link to its old
anchor — syllabus links, eclass posts, bookmarks.

**Expect stylesheet churn between machines.** Quarto's SASS bundler emits the
same declarations in a different order on different machines, which changes the
bootstrap file's content-hash and touches every generated page. The stylesheets
are equivalent and there is no visual difference; the diff simply flips back and
forth depending on who rendered last. Review the `.html` content changes and
ignore the `bootstrap-*.min.css` renames.

**Keep gitignore patterns anchored.** An unanchored `resources/` once matched
`_extensions/r-wasm/live/resources/` as well as the top-level PDF directory,
which excluded `tinyyaml.lua` — required on line 1 of the quarto-live filter.
The result was a repository that rendered for its author, whose untracked local
copy filled the gap, and for nobody else. If a render fails on a fresh clone but
works for you, suspect this first:

```bash
git check-ignore -v <path-that-should-exist>
```
