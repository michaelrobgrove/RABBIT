# Self-Hosting RABBIT

RABBIT is designed to be easily self-hosted. This is often the **best way to use the application** because it allows you to connect to IPTV services that use HTTP (which are blocked by browsers on secure HTTPS sites).

## 🚀 Quick Start (Recommended)

The fastest way to get running is using Python, which is installed on most computers.

1.  **Download RABBIT**
    *   [Download ZIP](https://github.com/michaelrobgrove/RABBIT/archive/refs/heads/main.zip) and extract it.
    *   OR `git clone https://github.com/michaelrobgrove/RABBIT.git`

2.  **Open Terminal/Command Prompt**
    *   Navigate to the RABBIT folder: `cd path/to/RABBIT`

3.  **Start the Server**
    ```bash
    # Python 3
    python -m http.server 8000
    ```

4.  **Open in Browser**
    *   Go to: [http://localhost:8000](http://localhost:8000)

---

## 🌐 Other Hosting Methods

Since RABBIT is a static site (just HTML/CSS/JS), you can host it with almost any web server.

### Node.js
```bash
npx http-server -p 8000
```

### PHP
```bash
php -S localhost:8000
```

### Docker
Create a `Dockerfile`:
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```
Build and run:
```bash
docker build -t rabbit .
docker run -d -p 8080:80 rabbit
```
Access at `http://localhost:8080`.

---

## 🔒 Proxy Setup (Advanced)

If you are hosting RABBIT on a public HTTPS server (like Cloudflare Pages or a VPS) and need to access HTTP IPTV streams, you must use a proxy.

**We provide a built-in proxy solution:**

1.  **Use the provided proxy script** (if available in your fork) or set up a simple Node.js CORS proxy.
2.  **Configure `index.html`**:
    *   Locate the `corsProxies` array in the JavaScript section.
    *   Add your proxy URL: `https://your-domain.com/proxy?url=`

This allows the application to route insecure HTTP requests through your secure proxy.

---

## 📱 Accessing from Other Devices

To use RABBIT on your phone or TV while running it on your computer:

1.  Find your computer's local IP address (e.g., `192.168.1.x`).
    *   Windows: `ipconfig`
    *   Mac/Linux: `ifconfig` or `ip addr`
2.  On your phone/TV browser, go to: `http://192.168.1.x:8000`

**Note:** Ensure your firewall allows incoming connections on port 8000.