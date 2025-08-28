# Bible Styler — Browser Edition (index.html)

Single‑file, zero‑dependency web app to “style” Bible verses using any OpenAI‑compatible Chat Completions API. This README covers only the `index.html` app.

- No build step, no server required
- Works with OpenAI‑compatible providers (OpenAI, OpenRouter, Groq, Together, Fireworks, DeepInfra, Cerebras, LM Studio, Ollama, etc.)
- Batch mode (many verses) and Single‑verse/chapter mode
- Settings and persona prompts saved locally in your browser (localStorage)
- Remembers last used mode (Batch vs. Single) and model/API settings

## Run It

Three easy options:

1) Use the hosted app (recommended)
- Open: https://helix4u.github.io/Bible-Styler/
- Because it’s HTTPS, browsers will block `http://localhost` API calls (mixed content). Use an HTTPS API endpoint (e.g., OpenAI, OpenRouter) when using the hosted page.

2) Open locally (file URL)
- Download or clone this repo
- Open `index.html` directly in a modern browser (Chrome/Edge/Firefox)

3) Serve locally over HTTP (best for local models like LM Studio or Ollama)
- From the folder with `index.html`, run a simple server, then visit `http://localhost:8000`:
  - Python: `python3 -m http.server 8000`
  - Node (serve): `npx serve . -l 8000`
- When the page is `http://`, calling `http://localhost:1234` (LM Studio) or `http://localhost:11434` (Ollama) works without mixed‑content issues.

Tip: You can also host it on your own GitHub Pages; in your repo go to Settings → Pages and enable Pages for the root. The URL will be `https://<user>.github.io/<repo>/index.html`.

## Quick Start

1. Vendor preset
- Pick a provider from “Vendor preset” to auto‑fill the API base URL (or choose “Custom” to paste your own)

2. API base and key
- `API base`: An OpenAI‑compatible chat completions endpoint (e.g., `https://api.openai.com/v1/chat/completions` or LM Studio/Ollama local endpoints)
- `API key`: Your provider key (stored only in this browser)

3. Model selection
- Click “Fetch” to load models from your provider, or toggle “type custom” and enter any model ID manually
- A minimal starter list is seeded on first load (now includes `gpt-4.1-mini`, `gpt-4.1-nano`)

4. Style system prompt (persona)
- Use a built‑in preset or write your own
- Built‑ins include: Stoner, Zoomer, House‑ish, Plain English, Kid‑Friendly, Headline, Legal Brief, Study Note, Clinical/Scientific, Minimalist, Tweet‑Length, Bold Bard, Pirate, Noir Detective, Sports Coach, Stoic Sage, Hacker Log
- Save/load up to 5 local persona slots

5. Load Scripture JSON
- Use the default URL (Book of Mormon + Bible dataset) or paste your own JSON URL, or choose a local `.json` file
- Optionally filter by volumes/books, and set index range

6. Run
- Batch mode: Click “Start” to process a range of verses; download results as `.txt`
- Single panel:
  - Single verse: Pick Book/Chapter/Verse (or type a custom line) and click “Run single verse”
  - Chapter: Select the Book/Chapter and click “Run chapter”
  - The original verse text shows as the textarea placeholder (not truncated)
 - Output controls: Use “Copy output” to copy all text, or “Share” to open the native share sheet (text‑only on mobile)

## Data Format (Scripture JSON)

Provide an array of objects with these keys:

- `volume_title` (string)
- `book_title` (string)
- `chapter_number` (number)
- `verse_number` (number)
- `scripture_text` (string)
- `verse_title` (string, optional; used for `[Book C:V]` prefix if present)

Example item:

```json
{
  "volume_title": "Old Testament",
  "book_title": "Genesis",
  "chapter_number": 1,
  "verse_number": 1,
  "scripture_text": "In the beginning God created the heaven and the earth.",
  "verse_title": "Genesis 1:1"
}
```

The UI also lets you filter by volume(s) and book(s) using comma‑separated lists.

## Providers and Endpoints

The app uses OpenAI‑style Chat Completions. Presets included:

- Custom
- LM Studio (local): `http://127.0.0.1:1234/v1/chat/completions`
- Ollama (OpenAI compat): `http://127.0.0.1:11434/v1/chat/completions`
- OpenAI: `https://api.openai.com/v1/chat/completions`
- OpenRouter: `https://openrouter.ai/api/v1/chat/completions`
- Together: `https://api.together.xyz/v1/chat/completions`
- Groq: `https://api.groq.com/openai/v1/chat/completions`
- Fireworks: `https://api.fireworks.ai/inference/v1/chat/completions`
- DeepInfra: `https://api.deepinfra.com/v1/openai/chat/completions`
- Cerebras: `https://api.cerebras.ai/v1/chat/completions`

Model list fetch is robust: it tries `/models`, `/v1/models`, and Ollama `/api/tags`. If model fetching fails, you can type a model ID manually. Your previously selected model is preserved if still available.

## Output Format

- Each line starts with `[Book Chapter:Verse]` (e.g., `[Genesis 1:1] …`)
- The app normalizes punctuation, removes noisy markers (e.g., `Reference:`), and ensures a minimum body length
- “Download .txt” saves all batch results locally
- “Copy output” copies the current Output pane
- “Share” uses the Web Share API (text‑only) when available; otherwise falls back to copying

## Options Explained

- Temperature: Creativity vs. determinism (0–2)
- Stream tokens: When true, uses SSE streaming; otherwise waits for full JSON response
- Stops: Comma‑separated stop strings sent as `stop` to the API
- Context pairs memory: How many recent (user, assistant) pairs to keep to reduce repetitive openings; may retry with higher temperature if repetition detected
- Extra headers: JSON object merged into the request headers (e.g., OpenRouter requires `HTTP-Referer` and `X-Title`)

## Privacy & Storage

- API keys and settings are stored only in your browser’s `localStorage`
- Nothing is sent anywhere except the JSON URL you fetch and the API endpoint you configure
- “Do not commit keys.” The page reminds you of this and never writes your key to the repo
 - Saves as you type; restores your last selections (including active tab: Batch vs Single)

## HTTPS, Localhost, and CORS

- Mixed content (hosted page): At `https://helix4u.github.io/Bible-Styler/`, browsers block `http://localhost…` calls. Use an HTTPS API endpoint, or run the page locally over `http://` to work with LM Studio/Ollama
- CORS: Your API and JSON host must allow cross‑origin requests from where you serve/open the page
- If model fetching fails due to CORS or auth, you can still type a model ID manually

## Mobile & Sharing

- Share button uses text‑only Web Share API on supported browsers (e.g., Chrome on Android)
- If sharing isn’t supported, the app falls back to copying the output to clipboard
- Very large outputs are trimmed to a safe length when sharing as text; for full content, use “Download .txt” or copy

## Troubleshooting

- “Failed …” when fetching models: Enter the model ID manually; confirm API base and key; check provider docs and CORS
- “HTTP 401/403”: Check your API key and account access to the model
- “Bad JSON file …”: Ensure the JSON is valid and matches the schema above
- Nothing happens on HTTPS with localhost API: Mixed content is blocked → switch to an HTTPS API or open the page over `http://`

## Notes

- Minimal seeded models are provided on first load to make the selector usable even before fetching (top: `gpt-4.1-mini`, then `gpt-4.1-nano`)
- The default Scripture URL may include multiple volumes; use the filters to narrow scope
- Mobile: UI is responsive; tabs are keyboard‑accessible (Enter/Space)
 - Output panel includes Copy and Share for quick mobile workflows

Enjoy! If this helps you, consider supporting: https://ko-fi.com/gille
