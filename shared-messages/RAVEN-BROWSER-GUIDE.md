# Raven's Browser Automation Guide

**Updated: 2026-02-25**
**Status: ✅ WORKING — Agent Browser skill ready (v0.14.0, Docker fix applied)**

---

## ⚠️ Docker Requirements (Critical)

The browser will NOT work without these Docker settings. If you see "Page crashed", these are missing:

1. **`shm_size: '512mb'`** in `docker-compose.yml` (Chromium needs >64MB shared memory)
2. **`seccomp:unconfined`** in `docker-compose.security.yml` (Chromium sandbox needs syscalls)
3. **`AGENT_BROWSER_ARGS=--no-sandbox,--disable-dev-shm-usage,--disable-gpu`** environment variable
4. **`SYS_ADMIN`** capability (for Chromium sandbox `clone()` calls)

Verify with:
```bash
docker exec openclaw-gateway df -h /dev/shm       # Should show 512M
docker exec openclaw-gateway cat /proc/1/status | grep Seccomp  # Should show 0
docker exec openclaw-gateway printenv AGENT_BROWSER_ARGS        # Should show flags
docker exec openclaw-gateway agent-browser --version             # Should show 0.14.0
```

If `agent-browser` is missing after a container rebuild:
```bash
docker exec -u root openclaw-gateway npm install -g agent-browser
```

---

## 🌐 What This Does

The **Agent Browser** skill lets you browse the web, fill forms, click buttons, read page content, take screenshots, and automate web workflows — all from inside the OpenClaw gateway container. Think of it as your hands on a web browser.

**Key use cases:**
- Demo web pages to Jeff (navigate, screenshot, read content)
- Fill out forms (login pages, registration, etc.)
- Read and extract data from web pages
- Monitor websites for changes
- Post to platforms that don't have APIs
- Take screenshots for reports

---

## Quick Reference

| Item | Value |
|---|---|
| **CLI tool** | `agent-browser` |
| **Version** | 0.14.0 |
| **Runs inside** | `openclaw-gateway` container |
| **Skill status** | ✅ ready (13/57 skills) |
| **Install source** | ClawHub / vercel-labs |

---

## 🚀 Core Workflow (Memorize This)

Every browser task follows this pattern:

```
1. OPEN a URL
2. SNAPSHOT to see what's on the page (get element refs)
3. INTERACT using refs (@e1, @e2, etc.)
4. RE-SNAPSHOT after any navigation or major page change
5. CLOSE when done
```

### Basic Example:

```bash
# Step 1: Open a page
docker exec openclaw-gateway agent-browser open https://www.moltbook.com

# Step 2: See what's on the page (interactive elements)
docker exec openclaw-gateway agent-browser snapshot -i

# Step 3: Click something using the ref from snapshot
docker exec openclaw-gateway agent-browser click @e3

# Step 4: Re-snapshot to see the new page state
docker exec openclaw-gateway agent-browser snapshot -i

# Step 5: Close when done
docker exec openclaw-gateway agent-browser close
```

---

## 📖 Command Reference

### Navigation

```bash
agent-browser open <url>          # Go to a URL
agent-browser back                # Browser back button
agent-browser forward             # Browser forward button
agent-browser reload              # Refresh the page
agent-browser close               # Close the browser
```

### Snapshot (See What's on the Page)

This is your **most important command**. It tells you what's on the page and gives you refs to interact with elements.

```bash
agent-browser snapshot            # Full page accessibility tree
agent-browser snapshot -i         # Interactive elements only (RECOMMENDED)
agent-browser snapshot -c         # Compact output (less verbose)
agent-browser snapshot -s "#main" # Only look inside a CSS selector
agent-browser snapshot -i --json  # Machine-readable JSON output
```

**Example output from `snapshot -i`:**
```
textbox "Email" [ref=e1]
textbox "Password" [ref=e2]
button "Sign In" [ref=e3]
link "Forgot password?" [ref=e4]
```

Use the `@e1`, `@e2` refs in subsequent commands.

### Clicking & Interacting

```bash
agent-browser click @e1           # Click an element
agent-browser dblclick @e1        # Double-click
agent-browser hover @e1           # Hover over element
agent-browser focus @e1           # Focus an element
agent-browser check @e1           # Check a checkbox
agent-browser uncheck @e1         # Uncheck a checkbox
agent-browser select @e1 "value"  # Select from dropdown
agent-browser scrollintoview @e1  # Scroll element into view
```

### Typing & Forms

```bash
agent-browser fill @e1 "text"     # Clear field, then type (USE THIS for forms)
agent-browser type @e1 "text"     # Type without clearing first
agent-browser press Enter         # Press a key
agent-browser press Tab           # Press Tab
agent-browser press Control+a     # Key combination (select all)
```

> **Always use `fill` instead of `type` for form fields** — it clears existing text first.

### Reading Page Content

```bash
agent-browser get text @e1        # Get text content of an element
agent-browser get html @e1        # Get the HTML of an element
agent-browser get value @e1       # Get input field value
agent-browser get attr @e1 href   # Get an attribute (e.g., link URL)
agent-browser get title           # Get page title
agent-browser get url             # Get current URL
agent-browser get count ".item"   # Count elements matching CSS selector
```

### Screenshots & PDF

```bash
agent-browser screenshot          # Screenshot to stdout (base64)
agent-browser screenshot /tmp/page.png  # Save screenshot to file
agent-browser screenshot --full   # Full-page screenshot (scroll)
agent-browser pdf /tmp/page.pdf   # Save page as PDF
```

### Waiting

```bash
agent-browser wait @e1            # Wait for element to appear
agent-browser wait 2000           # Wait 2 seconds
agent-browser wait --text "Done"  # Wait for text to appear
agent-browser wait --url "/dash"  # Wait for URL to contain pattern
agent-browser wait --load networkidle  # Wait for page to finish loading
```

### Tabs

```bash
agent-browser tab                 # List open tabs
agent-browser tab new <url>       # Open new tab
agent-browser tab 2               # Switch to tab 2
agent-browser tab close           # Close current tab
```

### Cookies & Login State

```bash
agent-browser cookies             # View all cookies
agent-browser cookies set name value  # Set a cookie
agent-browser cookies clear       # Clear all cookies
agent-browser state save /tmp/login.json   # Save session (cookies, storage)
agent-browser state load /tmp/login.json   # Restore saved session
```

### JavaScript

```bash
agent-browser eval "document.title"           # Run JS on the page
agent-browser eval "window.location.href"     # Get current URL via JS
```

---

## 🔑 Common Recipes

### Recipe 1: Read a Web Page

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://www.example.com
agent-browser snapshot -c
agent-browser close
'
```

### Recipe 2: Login to a Website

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://example.com/login
agent-browser snapshot -i
# Look at output for email/password field refs
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i
# Save login state for future use
agent-browser state save /tmp/example-auth.json
agent-browser close
'
```

### Recipe 3: Resume a Saved Login Session

```bash
docker exec openclaw-gateway bash -c '
agent-browser state load /tmp/example-auth.json
agent-browser open https://example.com/dashboard
agent-browser snapshot -i
'
```

### Recipe 4: Take a Screenshot for Jeff

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://www.moltbook.com
agent-browser wait --load networkidle
agent-browser screenshot /tmp/moltbook-screenshot.png
agent-browser close
'
# Copy screenshot to host if needed:
docker cp openclaw-gateway:/tmp/moltbook-screenshot.png /Users/jeffsutherland/clawd/
```

### Recipe 5: Check Moltbook Feed via Browser

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://www.moltbook.com
agent-browser wait --load networkidle
agent-browser snapshot -c
agent-browser close
'
```

### Recipe 6: Fill Out a Form and Submit

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://example.com/contact
agent-browser snapshot -i
# Refs from snapshot: textbox "Name" [ref=e1], textbox "Email" [ref=e2], 
#                     textarea "Message" [ref=e3], button "Send" [ref=e4]
agent-browser fill @e1 "Jeff Sutherland"
agent-browser fill @e2 "jeff@example.com"
agent-browser fill @e3 "Hello from the ASF team!"
agent-browser click @e4
agent-browser wait --text "Thank you"
agent-browser screenshot /tmp/form-submitted.png
agent-browser close
'
```

### Recipe 7: Search Google and Read Results

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://www.google.com
agent-browser snapshot -i
agent-browser fill @e1 "Agent Security Framework Scrum"
agent-browser press Enter
agent-browser wait --load networkidle
agent-browser snapshot -c
agent-browser close
'
```

### Recipe 8: Demo a Page to Jeff (Navigate + Screenshot Multiple Pages)

```bash
docker exec openclaw-gateway bash -c '
agent-browser open https://localhost:3001
agent-browser wait --load networkidle
agent-browser screenshot /tmp/demo-1-homepage.png

agent-browser snapshot -i
# Click on "Board" link
agent-browser click @e5
agent-browser wait --load networkidle
agent-browser screenshot /tmp/demo-2-board.png

agent-browser close
'
# Copy all screenshots to host
docker cp openclaw-gateway:/tmp/demo-1-homepage.png /Users/jeffsutherland/clawd/
docker cp openclaw-gateway:/tmp/demo-2-board.png /Users/jeffsutherland/clawd/
```

---

## ⚠️ Important Notes

### Refs Change After Navigation
- After `open`, `click` (that navigates), `back`, `forward`, or `reload` — **always re-snapshot** to get new refs
- Refs like `@e1` are only valid for the current page state

### Use `fill` Not `type` for Form Fields
- `fill` clears existing text first, then types — this is what you want 99% of the time
- `type` appends to existing text

### Headless by Default
- The browser runs headless (no visible window) inside Docker
- Use `--headed` flag if you need to see the browser window (only works if display is available)

### Timeouts
- Default timeout is reasonable but you can increase with `--timeout 30000` (30 seconds)
- Use `wait` commands to ensure pages are loaded before interacting

### Running Inside Docker
- All commands must be prefixed with `docker exec openclaw-gateway`
- Files saved inside the container (e.g., screenshots) can be copied out with `docker cp`

### Login Sessions
- Use `state save` / `state load` to persist login sessions between browser uses
- Save state files to `/tmp/` inside the container
- For persistent state, save to `/workspace/` (mapped to host volume)

---

## 🔒 Security Notes

- The browser runs inside the isolated Docker container
- Login credentials typed via `fill` are not logged by default
- Saved state files (`.json`) contain cookies — treat them as secrets
- Don't navigate to untrusted sites without reason

---

## Troubleshooting

### "Command not found"
```bash
# Verify installation
docker exec openclaw-gateway agent-browser --version
# Should show: agent-browser 0.14.0
```

### Element not found
```bash
# Re-snapshot to get current refs
docker exec openclaw-gateway agent-browser snapshot -i
```

### Page not loaded yet
```bash
# Add wait after navigation
docker exec openclaw-gateway agent-browser wait --load networkidle
```

### Need to see what the browser sees
```bash
# Take a screenshot
docker exec openclaw-gateway agent-browser screenshot /tmp/debug.png
docker cp openclaw-gateway:/tmp/debug.png /Users/jeffsutherland/clawd/
```

### Browser seems stuck
```bash
# Close and start fresh
docker exec openclaw-gateway agent-browser close
docker exec openclaw-gateway agent-browser open https://...
```

---

## 📋 Cheat Sheet

| Task | Command |
|---|---|
| Open page | `agent-browser open <url>` |
| See elements | `agent-browser snapshot -i` |
| Click | `agent-browser click @e1` |
| Type in field | `agent-browser fill @e1 "text"` |
| Press key | `agent-browser press Enter` |
| Screenshot | `agent-browser screenshot /tmp/pic.png` |
| Wait for load | `agent-browser wait --load networkidle` |
| Get text | `agent-browser get text @e1` |
| Get page title | `agent-browser get title` |
| Get URL | `agent-browser get url` |
| Save login | `agent-browser state save /tmp/auth.json` |
| Load login | `agent-browser state load /tmp/auth.json` |
| Close | `agent-browser close` |

**Remember: Always `snapshot -i` after navigating to get fresh refs!**

---

## 🔭 Interactive Pair-Programming — Work Together With Jeff in Real-Time

### Why This Matters

**Pair-programming between humans and AI agents is the most critical skill for hybrid Scrum teams.** The Interactive Browser Live View lets Jeff and Raven look at the same web page simultaneously, both able to click, type, scroll, and navigate. This is NOT a read-only view — it's a shared, interactive browser session.

This capability enables:
- **Joint demos** — walk through web pages together
- **Collaborative debugging** — both see the same error page
- **Guided form-filling** — Jeff logs in, Raven takes over
- **Real-time web research** — explore sites together
- **Pair review** — review dashboards, boards, and reports side by side

---

### Architecture

```
┌─────────────────────────────┐     ┌────────────────────────────────┐
│  Jeff's Browser (Chrome)     │     │  Docker: openclaw-gateway       │
│  http://localhost:8083       │◄───►│  agent-browser (Playwright)     │
│                              │     │  Chromium 145 (headless)        │
│  - Sees live screenshots     │     │                                 │
│  - Clicks → real clicks      │     │  Screenshot path:               │
│  - Types → real keystrokes   │     │  /workspace/.raven-live-view.png│
│  - Scroll, navigate, etc.    │     │                                 │
└─────────────────────────────┘     └────────────────────────────────┘
        ▲                                       ▲
        │                                       │
        │     ┌─────────────────────────┐       │
        └────►│  browser-live-view.py    │◄──────┘
              │  (Python server on Mac)  │
              │  Port 8083               │
              │  Bridges Docker ↔ Browser│
              └─────────────────────────┘
```

**Flow:**
1. `browser-live-view.py` runs on macOS, listens on port 8083
2. Jeff opens http://localhost:8083 in Chrome/Safari
3. The server calls `docker exec openclaw-gateway agent-browser screenshot` every 3 seconds
4. Screenshots are served to Jeff's browser as a live-updating image
5. When Jeff clicks the image, the server translates the click coordinates and sends `agent-browser mouse move/click` commands to the container
6. When Raven runs `agent-browser` commands, the screenshots update automatically
7. Both Jeff and Raven see changes in real-time

---

### Setup (One-Time)

**Prerequisites:**
- Docker running with `openclaw-gateway` container
- `agent-browser` v0.14.0 installed in the container
- Docker settings applied (shm_size: 512mb, seccomp: unconfined, SYS_ADMIN cap)
- Python 3 on the Mac host (already installed)

**No additional packages needed** — `browser-live-view.py` uses only Python stdlib.

---

### Starting a Pair-Programming Session

**Step 1 — Jeff starts the live view server:**
```bash
python3 /Users/jeffsutherland/clawd/browser-live-view.py
```

**Step 2 — Jeff opens the live view:**
```
http://localhost:8083
```

**Step 3 — Raven opens a page (or Jeff types a URL in the live view's address bar):**
```bash
docker exec openclaw-gateway agent-browser open https://scrumai.org
```

**Step 4 — Both can now interact:**
- Jeff clicks on the screenshot → clicks in the real browser
- Raven runs `agent-browser click @e3` → Jeff sees the result
- Jeff types in the address bar and clicks Go → new page loads
- Raven fills a form → Jeff watches in real-time

---

### Jeff's Live View Controls

| Control | What It Does |
|---|---|
| **URL bar + Go** | Navigate to any URL |
| **◀ ▶ ⟳** | Browser back, forward, reload |
| **Click on screenshot** | Clicks at that position in the real browser (coordinate-translated) |
| **📸 Capture** | Force an immediate screenshot refresh |
| **🔴 Live / ⚪ Paused** | Toggle auto-refresh (3 seconds) |
| **⬆ Scroll Up / ⬇ Scroll Down** | Scroll the page 400px |
| **⌨️ Type Text** | Opens a dialog to type text into the focused field |
| **↵ Enter** | Press Enter key |
| **⇥ Tab** | Press Tab key |
| **Esc** | Press Escape key |
| **📋 Elements panel** | Shows all interactive elements with refs (right sidebar) |
| **Click an element in the list** | Clicks that element by ref (@e1, @e2, etc.) |
| **Command bar** | Run any raw agent-browser command (e.g. `fill @e2 "hello"`) |
| **Action Log tab** | See history of all actions taken |

---

### Raven's Role During Pair-Programming

When pair-programming with Jeff through the live view, Raven should:

1. **Announce what you're about to do** before executing commands
2. **Wait for screenshots to update** (3 seconds) before reporting what you see
3. **Use `snapshot -i`** to read element refs and report them to Jeff
4. **Ask Jeff before filling sensitive fields** (passwords, payment info)
5. **Take screenshots at key moments** for documentation

**Example conversation flow:**
```
Raven: "I'll open scrumai.org now. You should see it in the live view."
[runs: agent-browser open https://scrumai.org]

Raven: "Page loaded. I can see the homepage with navigation links.
        Interactive elements: About Us @e7, Services @e8, Blog @e10.
        Want me to click on something?"

Jeff: "Click on Blog"

Raven: "Clicking Blog (@e10)..."
[runs: agent-browser click @e10]

Raven: "Blog page loaded. I can see the latest posts."
```

---

### Common Pair-Programming Workflows

#### Workflow 1: Review a Website Together
```bash
# Raven opens the site
docker exec openclaw-gateway agent-browser open https://scrumai.org
# Raven reports what she sees
docker exec openclaw-gateway agent-browser snapshot -i
# Jeff clicks around in the live view, Raven describes what they see
# Jeff can also type URLs in the address bar
```

#### Workflow 2: Jeff Logs In, Raven Takes Over
```bash
# Raven opens the login page
docker exec openclaw-gateway agent-browser open https://app.example.com/login
# Jeff types credentials directly via the live view Type Text button
# Jeff clicks the Login button in the live view
# Raven saves the session state
docker exec openclaw-gateway agent-browser state save /workspace/example-auth.json
# Raven continues navigating the authenticated site
docker exec openclaw-gateway agent-browser snapshot -i
```

#### Workflow 3: Collaborative Form Filling
```bash
# Raven opens the form
docker exec openclaw-gateway agent-browser open https://example.com/form
docker exec openclaw-gateway agent-browser snapshot -i
# Raven fills standard fields
docker exec openclaw-gateway agent-browser fill @e1 "Jeff Sutherland"
docker exec openclaw-gateway agent-browser fill @e2 "jeff@scruminc.com"
# Jeff reviews in live view, types additional details via Type Text
# Raven or Jeff clicks Submit
```

#### Workflow 4: Debug a Web Application Together
```bash
# Raven opens the app
docker exec openclaw-gateway agent-browser open http://localhost:3001
# Both examine the page
# Jeff clicks through different sections in the live view
# Raven reads error messages: agent-browser get text @e5
# Raven can run JS: agent-browser eval "document.querySelectorAll('.error').length"
```

---

### Troubleshooting the Live View

| Problem | Solution |
|---|---|
| **"No session" message in live view** | Start a browser session first: `docker exec openclaw-gateway agent-browser open https://example.com` |
| **Screenshot not updating** | Click 📸 Capture button. Check if agent-browser is running: `docker exec openclaw-gateway agent-browser get url` |
| **Click doesn't land on right spot** | Make sure the browser viewport matches. Try clicking elements in the sidebar panel instead (by ref) |
| **Type Text doesn't work** | First click on the input field (either in screenshot or via Elements panel), then use Type Text |
| **"Page crashed" in container** | Docker settings missing — see Docker Requirements section above |
| **Live view server won't start** | Check port 8083 isn't in use: `lsof -i :8083`. Kill any existing process. |
| **Server crashes** | Check that Docker is running: `docker ps \| grep openclaw-gateway` |

### File Locations

| File | Purpose |
|---|---|
| `/Users/jeffsutherland/clawd/browser-live-view.py` | Interactive live view server (Python, runs on Mac) |
| `/workspace/.raven-live-view.png` | Screenshot file inside container (auto-generated) |
| `~/clawd/.raven-live-view.png` | Screenshot file on Mac host (auto-generated) |

---

### Method 2: One-off Screenshot to Jeff's Desktop

For quick screenshots when the live view isn't running:

```bash
# Take screenshot inside container
docker exec openclaw-gateway agent-browser screenshot /tmp/page.png
# Copy to Jeff's machine
docker cp openclaw-gateway:/tmp/page.png /Users/jeffsutherland/clawd/page-screenshot.png
# Jeff can now open it
open /Users/jeffsutherland/clawd/page-screenshot.png
```

### Method 3: Annotated Screenshot (Numbered Labels)

```bash
docker exec openclaw-gateway agent-browser screenshot --annotate /tmp/annotated.png
docker cp openclaw-gateway:/tmp/annotated.png /Users/jeffsutherland/clawd/annotated.png
open /Users/jeffsutherland/clawd/annotated.png
```
This adds numbered labels to interactive elements — great for discussing what to click.

