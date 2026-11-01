# MalenaSpace — Malena's portfolio

A personal portfolio that looks like a 2006 MySpace profile opened in Internet Explorer 6 on a Windows XP desktop, with Frutiger Aero styling (sky, grass, glass, bubbles). It is the CV of Malena, a 4th-year Ingeniería en Sistemas Informáticos student at UAI (Buenos Aires) looking for a junior DevOps / sysadmin role.

The whole site is **one file**: `index.html`. No build step, no frameworks, no external requests, system fonts only.

## Run it locally

```bash
./serve.sh
```

Then open <http://localhost:8080>. The script binds to all interfaces, so on the same Wi-Fi you can also open it on a phone at `http://<your-LAN-IP>:8080` (find the IP with `ip -4 addr`).

Any static file server works too, for example `python3 -m http.server 8080`.

## What is on the page

Everything a recruiter needs, in MySpace clothing:

| MySpace box | Real content |
|---|---|
| Profile box + Blurbs | About: who Malena is, what she studies, the role she wants |
| Education & Experience | Degree, year, relevant courses, honest "no jobs yet" |
| This Site as a Project | How the site is built and deployed (Astro, Cloudflare Workers, GitHub Actions, 1Password) |
| Friend Space ("Malena has 4 projects") | Projects & labs: Linux server lab, Bash scripts, networking lab, this website |
| Latest Blog Entries | Notes: short posts about problems fixed and lessons learned |
| Skills & Certifications | Only tools actually used, plus certifications in progress |
| Contacting Malena | GitHub, LinkedIn, email |

Around it: a working XP desktop (Start menu, taskbar, tray, desktop icons, small windows), a working IE6 window (Back/Forward, address bar, menus, status bar), a chiptune profile song, comments you can post, a hit counter, bubbles that pop, cursor sparkles, and an XP boot and Welcome screen.

## Editing content

Search `index.html` for the section you want. Section anchors:

`#about` · `#education` · `#this-site` · `#projects` · `#notes` · `#skills` · `#contact` · `#comments`

Things that are still placeholders and need real values:

- GitHub, LinkedIn and email links in **Contacting Malena** (search for `github.com/malena`, `linkedin.com/in/malena`, `malena@example.com`).
- The four project write-ups and the three blog posts are realistic examples; rewrite them with your own labs and notes.
- The "studying for Linux+ or CCNA" line under Skills.
- The fake address `www.malenaspace.com` in the IE address bar, once you own a domain.

## Handy URLs

Add `?ui=` to jump straight to a UI state (useful for screenshots and debugging). Examples:

- `?ui=nointro` — skip the boot and Welcome screen
- `?ui=startmenu` — Start menu open
- `?ui=dialog:about` — Help > About Internet Explorer
- `?ui=project:1` — Properties dialog of the first project
- `?ui=chat` — the MSN-style conversation window

The full list is in the comment at the top of the `<script>` block and in `TECHNICAL.md`.

## Screenshots

```bash
./shot.sh out.png 1280 900 nointro,startmenu   # headless Firefox, viewport only
./shot.sh phone.png 400 800 nointro
```

## Accessibility

Keyboard works everywhere (Tab, Enter, Space, Esc, arrow keys in menus), dialogs trap focus and return it, every control has a name, text contrast is at least 4.5:1, and all motion is disabled under `prefers-reduced-motion` or via Tools > Internet Options > Reduce motion. Sound never plays before you interact, and the tray volume icon mutes it.

## Where this is going

The plan from the project brief: move this into an **Astro** project, deploy it as a **Cloudflare Worker with static assets** using `wrangler`, deploy automatically with **GitHub Actions** on every push to `main` (install, build, deploy, `curl` smoke test), and keep every secret in **1Password** referenced with `op://` URIs. See `TECHNICAL.md` for how the file is organised and how to split it for Astro.