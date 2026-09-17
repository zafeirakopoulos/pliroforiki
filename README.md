# Πληροφορική Ι — interactive lecture notes

Course notes for **141. Πληροφορική Ι**, Department of Mathematics, National and
Kapodistrian University of Athens. Written in [Quarto](https://quarto.org) with
[quarto-live](https://github.com/r-wasm/quarto-live), so every Python example
runs in the reader's browser via Pyodide — no install, no server.

Published at <https://zafeirakopoulos.github.io/pliroforiki/>.

## Repository layout

Two branches, two different things:

| Branch | Holds | Who writes it |
| --- | --- | --- |
| `main` | the `.qmd` sources | you |
| `gh-pages` | the rendered HTML that GitHub Pages serves | GitHub Actions, never by hand |

Sources live at the root: `main.qmd`, `week1.qmd` … `week13.qmd` for the notes,
and `week1-slides.qmd` … `week13-slides.qmd` for the matching decks. Each file
carries its own `format:` block; `_quarto.yml` only wires up shared branding and
the output directory.

## Publishing

Push to `main`. That is the whole procedure.

Every push triggers the **Publish site** workflow
(`.github/workflows/publish.yml`), which renders the site on GitHub and replaces
the contents of `gh-pages` with the result. The live site updates a minute or two
after the workflow finishes. Progress and any errors are under the repository's
**Actions** tab; a failed build leaves the live site untouched.

To republish without changing anything, run the workflow by hand from the
Actions tab (**Run workflow**).

Nothing needs to be installed locally to publish.

## Previewing locally (optional)

To see pages as you write them, before pushing, install Quarto and a Jupyter
kernel. Two requirements are easy to get wrong, and neither fails with an
obvious message.

### 1. Quarto 1.8.25 specifically

Use the version the workflow pins, so the preview matches what gets published.

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

### 3. Preview

```bash
export PATH="$HOME/.local/bin:$PATH"
export QUARTO_PYTHON="$HOME/.local/opt/quarto-venv/bin/python"

quarto preview    # serve with live reload while writing
```

`quarto render` builds into `_site/`, which is ignored by git. A local render is
only ever a preview: the published site is always the one GitHub Actions builds.

## Notes for contributors

**Renaming a heading changes its anchor.** Quarto derives section ids from
heading text, so retitling a section silently breaks any link to its old
anchor — syllabus links, eclass posts, bookmarks.

**Expect a bootstrap filename change in `gh-pages` diffs.** Quarto's SASS
bundler emits the same declarations in a different order on different machines,
which changes the bootstrap stylesheet's content-hash and touches every generated
page. The stylesheets are equivalent and there is no visual difference. Since
every build now runs on the same GitHub runner image, this should appear only
when that image or Quarto changes, not on every publish.

**Changing the Quarto version** means editing `version:` in
`.github/workflows/publish.yml`. Expect the next publish to touch every page.

**Keep gitignore patterns anchored.** An unanchored `resources/` once matched
`_extensions/r-wasm/live/resources/` as well as the top-level PDF directory,
which excluded `tinyyaml.lua` — required on line 1 of the quarto-live filter.
The result was a repository that rendered for its author, whose untracked local
copy filled the gap, and for nobody else. If a render fails on a fresh clone but
works for you, suspect this first:

```bash
git check-ignore -v <path-that-should-exist>
```
