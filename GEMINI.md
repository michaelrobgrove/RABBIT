# RABBIT Project Context

## Project Overview
**RABBIT** is a modern, privacy-focused, open-source IPTV player. It is a lightweight web application designed to play M3U playlists and Xtream Codes API streams directly in the browser without backend storage or tracking.

## Technology Stack
*   **Frontend:** Pure HTML5, CSS3, and JavaScript (ES6+).
    *   **Single File:** The entire application logic and styling are embedded within `index.html`.
    *   **No Build Step:** No bundlers (Webpack, Vite) or frameworks (React, Vue) are used.
*   **Backend (Optional Proxy):** Node.js with Express.
    *   Used to bridge HTTP streams to HTTPS deployments and handle CORS restrictions.
    *   Documented in `PROXY_SERVER.md`.

## Key Files & Directories
*   `index.html`: The core application. Contains all markup, styles, and scripts.
*   `README.md`: Main entry point for documentation, features, and quick start.
*   `PROXY_SERVER.md`: Comprehensive guide for setting up a CORS/HTTPS proxy (critical for HTTP streams).
*   `DEPLOYMENT.md`: Instructions for deploying to various platforms (Cloudflare, Vercel, etc.).
*   `LOCAL_HOSTING.md`: Guide for running the player locally.
*   `images/`: Contains static assets like `rabbit.svg`.
*   `install-windows.bat`: Helper script for Windows setup.
*   `setup-proxy.sh`: Helper script for setting up the proxy on Linux.

## Usage & Development

### Running Locally
Since the project is a static site, it can be served with any simple HTTP server.

**Python:**
```bash
python -m http.server 8000
# Access at http://localhost:8000
```

**Node.js:**
```bash
npx http-server
```

### Deployment
*   **Static Hosts:** Cloudflare Pages, GitHub Pages, Netlify.
*   **Self-Hosted:** Can be hosted on any web server (Nginx, Apache).

### Proxy Setup
For full compatibility with HTTP IPTV services on HTTPS hosted versions, a proxy is required.
Refer to `PROXY_SERVER.md` for setting up a Node.js proxy with Cloudflare Tunnel or Nginx.

## Architecture Guidelines
*   **Privacy First:** No user data is sent to any server. Credentials stay in `sessionStorage`.
*   **Simplicity:** Maintain the "single file" structure for `index.html` where possible to ensure ease of deployment and portability.
*   **Visual Identity (STRICT):** The current UI style is final. This includes:
    *   **Landing Page:** Marketing-focused "sales" page with hero section, features grid, privacy badge, and Buy Me A Coffee link.
    *   **Player Layout:** A "Classic" pro layout featuring a main video stage with custom overlay controls and a 3-tab sidebar (Categories, Channels, Guide).
    *   **Color Palette:** Cobalt blue accents on a primary black/secondary black background.
*   **Smart Proxying:** The application implements a "Smart Proxy" fallback mechanism.
    *   **Priority:** Direct Connection -> User's Proxy (`ether.tfplus.stream`) -> Public CORS Proxy (`corsproxy.io`) -> `thingproxy.freeboard.io`.
    *   **User-Agent:** Always signals `IPTVSmartersPro` to the proxy/provider.
*   **Technical Stack:** HLS.js for universal stream playback and real-time "Stats for Nerds" (Bitrate, Resolution, Buffer).
