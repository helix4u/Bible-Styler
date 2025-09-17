# AGENTS: Scripture Styler (Browser Edition)

Authoritative guidance for agents working in this repository. The scope of this file is the entire repo.

## Repo Overview
- Single-file web app: `index.html` contains HTML, CSS, and JS.
- No build step, bundler, or server by default.
- Data example: `bhagavad_gita.json` (used as an example Scripture JSON source).

## Core Principles
- Keep it single-file. Do not split JS/CSS into separate files unless explicitly requested.
- Zero external dependencies. Avoid adding npm/yarn, package.json, or CDNs.
- Minimal, focused diffs. Preserve existing structure and naming; avoid renames.
- No secrets. Never hardcode API keys or tokens; the app uses localStorage in-browser.
- Consistency. Match current formatting and style (2-space indents, plain ES6, DOM APIs).

## When Editing `index.html`
- Keep all logic inline within the file; prefer small, well-named functions.
- Maintain accessibility and responsive layout patterns already present.
- Preserve existing IDs and classes used by the UI unless refactoring is explicitly requested.
- Favor progressive enhancement and graceful failure for optional features.
- Avoid introducing frameworks (React/Vue/etc.) or build tooling.

## Serving & Running
- Option A: Open `index.html` directly in a modern browser.
- Option B: Serve locally over HTTP for local APIs (recommended):
  - Python: `python3 -m http.server 8000` (then visit `http://localhost:8000`)
  - Node: `npx serve . -l 8000`
- Hosted page: `https://helix4u.github.io/Bible-Styler/` (HTTPS blocks `http://localhost` API calls).

## API/Model Notes
- Targets OpenAI-compatible Chat Completions endpoints.
- Not all models returned by providers support Chat Completions; keep model handling defensive.
- Keep provider-agnostic logic; do not hardcode provider-specific quirks unless behind feature detection.

## Data Format Expectations
- Scripture JSON is an array of objects with keys:
  - `volume_title` (string)
  - `book_title` (string)
  - `chapter_number` (number)
  - `verse_number` (number)
  - `scripture_text` (string)
  - `verse_title` (string, optional)
- If changing parsing/filters, ensure batch and single-verse modes both continue to work.

## Performance & UX
- Keep the page snappy; avoid large libraries and heavy reflows.
- Stream handling should not block UI; keep UI responsive during requests.
- Preserve mobile-friendly behavior, keyboard navigation, and localStorage persistence.

## Testing & Validation
- Manual checks: open/serve the page, verify both Batch and Single modes.
- Test with: a local JSON file, a remote JSON URL, and a few API providers (or a local server like LM Studio/Ollama).
- Ensure no secrets are written to the repo or logs.

## Pull Request/Change Hygiene
- Small, atomic commits/patches; descriptive messages.
- Do not introduce unrelated refactors.
- Do not add linters/formatters or CI without explicit request.
- Do NOT push to `main` without an explicit user request. Prepare changes locally and await approval before pushing.
- Approval-first workflow is mandatory: never perform network-affecting actions (pushes, releases, tags, external calls that change remote state) without the user explicitly asking for them in this session. Always summarize intended actions and wait for confirmation.

## Cross-References Policy (Study Aids)
- Cross-references must remain within the same corpus/tradition as the active dataset. The UI injects constraints, but when adding new sources ensure mappings are covered:
  - Quran — only Quran. Cite as SurahName S:V (e.g., Al-Baqarah 2:255).
  - Bhagavad Gita — only Bhagavad Gita. Cite as Bhagavad Gita C:V.
  - Dhammapada — only Dhammapada. Cite as Dhammapada C:V.
  - Tao Te Ching — only Tao Te Ching. Cite as Tao Te Ching C:V.
  - Tanakh (Torah/Nevi'im/Ketuvim) — only Tanakh. Cite as [Book C:V].
  - Bible (Old/New Testament) — only Bible. Cite as [Book C:V].
  - LDS volumes (Book of Mormon, Doctrine and Covenants, Pearl of Great Price) — only LDS Standard Works. Cite as [Book C:V].
- When adding a new dataset, extend the corpus detection and citation hint in index.html (function corpusHint()).## Adding New Datasets
- Prefer public domain or permissive sources (Project Gutenberg, Wikisource, Sefaria PD exports).
- Map into standard schema: `volume_title`, `book_title`, `chapter_number`, `verse_number`, `scripture_text`, `verse_title`.
- Keep chapter/verse semantics natural for the tradition (e.g., Surah/Ayah for Quran, Book/Saying for Analects, Chapter/Line for Tao Te Ching).
- Add a preset entry with a stable raw URL inside this repo; update README “Data Sources” with attribution and license.

## Nice-to-Have (when requested)
- Inline comments in `index.html` for non-obvious logic.
- Short notes in `README.md` if UX changes or new options are added.

---
If a change seems to require new tooling or multi-file structure, pause and request explicit approval before proceeding.





