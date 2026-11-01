# Technical details

## At a glance

- One file, `index.html`, about 5,350 lines / 340 KB: `<style>` first, then the HTML, then one `<script>` at the end.
- No dependencies, no network requests, no fonts loaded from the web. All icons are inline SVG (`<symbol>` sprites referenced with `<use>`) or CSS art. Audio is synthesized with the Web Audio API.
- Everything is static and client-side, so it can be hosted anywhere that serves files: Cloudflare Workers static assets, GitHub Pages, a `python3 -m http.server`.
- Tested with headless Firefox screenshots at 1280×900, 1440×900, 1024×768 and 400×800.

## Layout of the file

### CSS (top of the file)

The stylesheet is organised in the order the features were built. Each block starts with a `/* ---------- ... ---------- */` banner you can search for:

1. **Base + Aero world**: CSS variables, sky-to-grass gradient, clouds, sun glare, bubbles.
2. **The XP / IE window**, **page viewport** (the part that scrolls), **two-column MySpace grid**, **glass boxes with glossy headers**, **taskbar**, **responsive** rules.
3. **XP shell**: IE window as a real window, desktop icons, small XP windows, taskbar controls, tooltip, balloon tip, Start menu, dialogs, power states, mobile rules.
4. **IE6 realism**: menu bar, toolbar, address bar, client body + error page, status bar, dialogs (Save As, Internet Options, About), toast, settings overrides.
5. **MySpace 2006**: Post Comment button, comments form and cards, odometer hit counter, mood, blog read-more, project tiles, contact grid, MSN conversation window, profile song.
6. **Aero / Y2K + motion**: Welcome screen, bubble pop, pressed states, tooltips, logo shine, reveal and window animations.

Design tokens live in `:root`: `--sky-top`, `--sky-mid`, `--horizon`, `--grass-top`, `--grass-bot`, `--aero-blue`, `--aero-cyan`, `--aero-deep`, `--xp-blue`, `--xp-blue-dark`, `--glass`, `--glass-strong`, `--glass-border`, `--ink`, `--ink-soft`, `--link`, `--link-hover`, `--focus`, `--accent-green`, `--head-font`, `--table-font`.

Breakpoint: `max-width: 760px` is "mobile". The IE window becomes fixed full-screen, desktop icons hide (everything is reachable from the Start menu), menus go full width, the two columns stack.

### HTML

- A fixed **desktop** layer (`.desk`) with the Aero background, desktop icons and the floating bubbles.
- The **IE window** containing: title bar, menu bar (`role="menubar"`), toolbar, address bar (a real `<input>`), optional explorer bar, the **client area** (`main.viewport`, the only thing that scrolls on desktop), and the status bar.
- Inside the client area, the MySpace profile: left column (profile box, profile song, Contacting, Interests, Details, Skills, Education, hit counter) and right column (Extended Network, Latest Blog Entries, Blurbs, Friend Space, This Site as a Project, Friends Comments).
- The **taskbar** (Start button, task buttons, tray with volume, network, 1Password key, online status, clock).
- `<template>` elements for windows that are created on demand: `tpl-labs`, `tpl-notes`, `tpl-source`, `tpl-recycle`, `tpl-computer`, `tpl-chat`.
- Section anchors: `about`, `education`, `this-site`, `projects`, `notes`, `skills`, `contact`, `comments`.

### JavaScript

One IIFE builds the `XP` namespace, exposed as `window.XP` for console debugging. It is split into small modules, each an object with an `init()`:

| Module | Responsibility |
|---|---|
| `wm` / `wins` | Window manager: drag, z-order, active/inactive title bars, minimize/maximize/close, task buttons; small windows from templates |
| `ie` | The IE window itself; toolbar buttons, keyboard shortcuts (F5, Alt+Left/Right, Ctrl+S/O/F/D/E/I/H) |
| `nav` | In-page history for Back/Forward, address bar parsing, the "page cannot be displayed" error page, status bar progress, `history.replaceState` to keep the real hash in sync |
| `menus` / `commands` | Menu bar built from data; every item maps to a command |
| `explorerBar` | Favorites / Search / History panes |
| `dialog` / `openDialog(opts)` | Reusable XP modal: `role="dialog"`, `aria-modal`, focus trap, Esc, `inert` on the rest, focus return, default button, draggable |
| `start`, `balloon`, `tip`, `toast`, `power` | Start menu, tray balloon, XP tooltips (`data-tip`), toast, Turn Off / Stand By / Log Off screens |
| `settings` | Internet Options dialog: sounds, reduce motion, bubbles, sparkles, text size |
| `sound`, `volume`, `player` | Web Audio SFX, tray volume popup with mute, chiptune profile song |
| `comments`, `counter`, `mood`, `blog`, `projects`, `contact`, `chat` | MySpace features: comment form, odometer, mood select, read-more, project Properties dialogs, contact button dialogs, MSN conversation window |
| `bin` | Recycle Bin contents, empty/restore |
| `welcome`, `session`, `bubbles`, `sparkles`, `motion` | Boot + Welcome screen, session timer, bubble pop, cursor sparkles, reveal/window animations |

Conventions inside the script:

- `anim()` returns false under `prefers-reduced-motion`, when Reduce motion is on in Internet Options (`html.reduce-motion`), or when a `?ui=` parameter is present. Every animation checks it.
- `store.get/set(key, session?)` wraps `localStorage` / `sessionStorage` in try/catch; storage can be unavailable and the page must still work.
- User-entered text (comments, chat, Notepad) is inserted with `textContent`, never `innerHTML`.
- Audio: nothing is created or played until the first user gesture, and every sound checks the mute flag.

### Storage keys

| Key | Store | Purpose |
|---|---|---|
| `ms-comments` | localStorage | Posted comments (capped at 20) |
| `ms-hits` | localStorage | Hit counter value (starts at 1337) |
| `ms-mood` | localStorage | Selected mood |
| `xp-settings` | localStorage | Internet Options (sounds, reduce motion, bubbles, sparkles, text size) |
| `xp-muted`, `xp-volume` | localStorage | Tray volume state |
| `xp-welcomed` | sessionStorage | Welcome screen already shown this session |
| `xp-balloon-shown` | sessionStorage | "Malena is now online!" balloon already shown |

Clear them from the console with `localStorage.clear(); sessionStorage.clear()`.

## The `?ui=` debug hook

`index.html?ui=a,b,c` opens UI states on load so screenshots are deterministic. When any `?ui=` value is present, entrance animations, the automatic balloon, the boot progress and the Welcome screen (unless `login` is listed) are suppressed.

Shell: `nointro`, `startmenu`, `minimized`, `maximized`, `inactive`, `closed`, `dialog:close`, `dialog:logoff`, `dialog:emptybin`, `dialog:help`, `shutdown`, `shutdown:bye`, `shutdown:off`, `standby`, `win:labs`, `win:notes`, `win:recycle`, `win:computer`, `balloon`, `binempty`.

IE6: `menu:file|edit|view|favorites|tools|help`, `menu:view:textsize|toolbars|explorer|goto`, `dialog:about`, `dialog:saveas`, `dialog:options`, `dialog:addfav`, `dialog:open`, `dialog:find`, `dialog:properties`, `dialog:tip`, `dialog:detect`, `error`, `nav:<section>`, `loading`, `bar:favorites|search|history`, `textsize:<largest|larger|medium|smaller|smallest>`, `nostatus`.

MySpace: `comment`, `commenterror`, `project:<1-4|linux|bash|net|site>`, `chat`, `blogcomments:<1-3>`, `readmore:<1-3>`, `volume`, `mood:<name>`, `contact:<message|forward|friends|favorites|im|block>`, `sparkles`.

Aero / motion: `login`, `login:loading`, `tooltip`, `popped`, `boot`, `reveal`, `attention`.

The authoritative list is the comment at the top of the `<script>`.

## Verification commands

```bash
# HTML well-formed
python3 -c "import html.parser,sys; p=html.parser.HTMLParser(); p.feed(open('index.html').read()); print('parsed')"

# JS syntax
python3 - <<'EOF'
import re,subprocess
s=open('index.html').read()
for i,m in enumerate(re.finditer(r'<script[^>]*>(.*?)</script>',s,re.S)):
    open(f'/tmp/script{i}.js','w').write(m.group(1)); print(subprocess.run(['node','--check',f'/tmp/script{i}.js']))
EOF

# No external assets
grep -nE '<(script|link|img)[^>]+(src|href)="https?://' index.html || echo "none"

# Screenshots (headless Firefox)
./shot.sh desktop.png 1280 900 nointro
./shot.sh phone.png 400 800 nointro
```

## Porting to Astro (the planned stack)

The page is static, so the port is a reorganisation, not a rewrite:

1. `npm create astro@latest` (empty template). Put the `<style>` into `src/styles/site.css` and the `<script>` into `public/xp.js` (load it with `<script src="/xp.js" is:inline>` so Astro leaves it alone), or keep both inline in a layout at first.
2. Make `src/layouts/Desktop.astro` (desktop, taskbar, IE window chrome, templates) and components for the profile boxes (`ProfileBox.astro`, `GlassBox.astro`, `FriendSpace.astro`, ...).
3. Turn projects and notes into **content collections**: `src/content/projects/*.md` and `src/content/notes/*.md` with frontmatter (`title`, `date`, `summary`, `tags`). Render them into the Friend Space tiles, the write-ups and the blog list. Adding a post becomes adding one Markdown file.
4. Keep the section ids and the `data-*` hooks the script relies on (the `nav` module's `PAGES` table maps section ids to "pages"), and keep the `?ui=` hook; the screenshot checks keep working against `npm run dev`.
5. `wrangler.jsonc` with `"workers_dev": false`, the custom domain, and `assets` pointing at `dist/`. GitHub Actions on push to `main`: `npm ci`, `npm run build`, `npx wrangler deploy`, then `curl -sf https://<domain>/ -o /dev/null`. Secrets (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`) come from 1Password via `op read ... | gh secret set ...`; local deploys use `op run --env-file=.env.op -- npx wrangler deploy`.
6. Add an Open Graph image and tags in the layout `<head>` so links preview on WhatsApp and LinkedIn.

## Known limitations

- Headless screenshots verify layout, not touch. Real-device testing on iOS Safari and Android Chrome is still worth doing (100vh behaviour, `backdrop-filter` performance).
- Window dragging, cursor sparkles and pointer parallax are desktop-only by design.
- The IE address bar accepts only the site's own "pages"; anything else shows the IE6 error page on purpose.
- Browser support targets current Firefox, Chrome and Safari; `inert`, `scrollbar-color` and `backdrop-filter` are used and degrade gracefully where missing.