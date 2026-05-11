# 🌐 Calibration Calculator — PWA / TWA

Progressive Web App version of the Calibration Calculator. Same calculations
as the Flutter app, packaged as static HTML/CSS/JS with a Service Worker for
offline use, and ready to be wrapped as a TWA (Trusted Web Activity) on
Android.

## Local development

```bash
cd twa
python3 -m http.server 8000
# open http://localhost:8000
```

The Service Worker only registers on `http://` or `https://` (not `file://`),
so always serve via a local HTTP server.

## Icons

Source SVGs live in `icons/icon.svg` and `icons/icon-maskable.svg`. They are
the single source of truth.

**On CI** the PNGs are generated automatically with `rsvg-convert`
(see `.github/workflows/pwa-deploy.yml`).

**Locally**, open `icons/generate.html` in a browser, click each Download
link, and save the files alongside the SVGs:

| File                          | Size     | Purpose                  |
| ----------------------------- | -------- | ------------------------ |
| `Icon-192.png`                | 192×192  | PWA manifest             |
| `Icon-512.png`                | 512×512  | PWA manifest             |
| `Icon-maskable-192.png`       | 192×192  | Maskable (Android)       |
| `Icon-maskable-512.png`       | 512×512  | Maskable (Android)       |
| `apple-touch-icon.png`        | 180×180  | iOS home screen          |
| `favicon-32.png`              | 32×32    | Browser tab favicon      |

## Deploy

Pushes to `main` that touch `twa/**` trigger the GitHub Pages deployment
workflow. The workflow:

1. Renders icons from SVG
2. Stamps `sw.js` with the commit SHA (forces a cache reset on each deploy)
3. Uploads `twa/` to GitHub Pages

To force a manual deploy: Actions → "Deploy PWA to GitHub Pages" → Run.

## Wrapping as a TWA

To publish as a TWA on Google Play:

1. Host the PWA at a stable HTTPS URL (e.g., GitHub Pages, Netlify).
2. Generate the upload keystore SHA-256 fingerprint and put it into
   `.well-known/assetlinks.json` (currently `REPLACE_WITH_…`):

   ```bash
   keytool -list -v -keystore /path/to/upload-keystore.jks -alias upload \
       | grep -A1 "SHA256:"
   ```

3. Re-deploy so the live site serves the updated `assetlinks.json`.
4. Use [Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap) to
   generate the TWA Android project, signed with the **same keystore** as
   the Flutter app to avoid Play Store package-id conflicts.

## Service Worker cache strategy

- **Navigation requests** → network-first, fall back to cached `index.html`
- **Same-origin assets** → stale-while-revalidate
- **Cross-origin (fonts)** → cache-first with background refresh

`CACHE_NAME` is derived from `BUILD_TAG` at the top of `sw.js`. CI overrides
`BUILD_TAG` with the commit SHA on every deploy, so users always get fresh
assets without manual cache busting.

## File map

```
twa/
├── index.html              # Markup + iOS PWA meta tags
├── app.js                  # All logic + SW registration
├── styles.css              # Design system + system-font fallbacks
├── sw.js                   # Service Worker (BUILD_TAG-stamped)
├── manifest.json           # PWA manifest (with shortcuts + maskable)
├── icons/
│   ├── icon.svg            # Source — 512px viewBox
│   ├── icon-maskable.svg   # Source — full-bleed for Android
│   └── generate.html       # Local rasteriser (open in browser)
└── .well-known/
    └── assetlinks.json     # Digital Asset Links template for TWA
```
