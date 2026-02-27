# Prompt for Copilot: Fix Raven's Browser Tab Visibility

## Problem
Raven (Agent Saturday) cannot see any browser tabs in Chrome, preventing her from interacting with web pages alongside Jeff.

## Current Symptoms
1. **Browser tool returns empty tabs**: `{"tabs": []}` when querying Chrome profile
2. **Browser status shows issues**:
   - `running: false`
   - `cdpReady: false`
   - `chosenBrowser: null`
   - `detectedBrowser: null`
3. **Error when attempting snapshot**: "Chrome extension relay is running, but no tab is connected. Click the OpenClaw Chrome extension icon on a tab to attach it"

## What Works
- OpenClaw extension icon is visible in Chrome
- Jeff can click the extension icon
- The extension shows as "running" in the system
- Gateway appears to be running

## What Doesn't Work
- After Jeff clicks the extension icon to connect a tab, Raven doesn't see it
- The CDP (Chrome DevTools Protocol) connection isn't being established
- Raven sees 0 tabs regardless of what Jeff does

## What Needs to Be Fixed
1. **Debug why the tab connection isn't being detected**:
   - Check if the extension is properly registering connected tabs
   - Verify the CDP WebSocket is accepting connections
   - Check if there's a port mismatch (ports may have been reconfigured recently)

2. **Ensure tabs appear when Jeff clicks the extension**:
   - After clicking, Raven should see the tab in `browser action=tabs profile=chrome`
   - Then Raven should be able to `browser action=snapshot profile=chrome` to see the page

3. **Test workflow**:
   - Jeff opens a tab (e.g., jvsmanagement.com)
   - Jeff clicks OpenClaw extension icon
   - Raven runs `browser action=tabs profile=chrome` and sees the tab
   - Raven runs `browser action=snapshot profile=chrome` and sees the page content

## Environment Details
- OpenClaw version: 2026.2.19 (e68b545)
- Chrome extension relay is running
- CDP Port currently showing: 18792
- Profile: chrome

## Success Criteria
Raven can see and interact with browser tabs that Jeff connects via the Chrome extension.
