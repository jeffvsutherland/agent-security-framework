# ASF Website Publishing Guide

## Overview

This guide covers how to publish the ASF website to WordPress.

## Prerequisites

- WordPress admin access to scrumai.org
- Google Doc with website content
- AI publishing tool access

## Publishing Steps

### 1. Prepare Content in Google Docs

1. Copy content from `WEBSITE-CONTENT.md` to Google Docs
2. Format with Moltbot-inspired design:
   - Dark theme with accent colors
   - Clean typography
   - Prominent CTAs
3. Add images/screenshots

### 2. WordPress Publishing

Option A: Use AI publishing tool
```bash
# If using AI publishing tool
./publish-to-wordpress.sh --doc "ASF Website Content" --url https://scrumai.org/agentsecurityframework
```

Option B: Manual WordPress
1. Login to WordPress admin
2. Create new Page: "Agent Security Framework"
3. Copy content from Google Doc
4. Apply Moltbot-style theme
5. Add GitHub link button
6. Publish

### 3. Configure Domain

Ensure redirects work:
- scrumai.org/agentsecurityframework → WordPress page

### 4. Verify

- [ ] Page loads at correct URL
- [ ] GitHub link prominent
- [ ] Design matches Moltbot style
- [ ] All links work
- [ ] Mobile responsive

## Troubleshooting

### Common Issues

1. **Page not found**
   - Check WordPress permalink settings
   - Verify page slug: /agentsecurityframework

2. **Images not loading**
   - Check WordPress media library
   - Verify image URLs

3. **Design broken**
   - Apply Moltbot theme
   - Check CSS compatibility

## Content Update Process

To update website:
1. Edit WEBSITE-CONTENT.md
2. Update Google Doc
3. Republish to WordPress
4. Verify changes
