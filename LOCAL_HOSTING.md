# Quick Start: Run RABBIT Locally for HTTP IPTV Services

## Why Run Locally?

Many IPTV services use HTTP (not HTTPS). When RABBIT is hosted on HTTPS (like Cloudflare Pages), browsers block HTTP content for security reasons.

**Solution**: Run RABBIT locally on your computer using HTTP. This allows HTTP IPTV services to work perfectly!

---

## 🚀 Super Quick Start (30 seconds)

### Option 1: Python (Easiest - Works on Mac/Linux/Windows)

```bash
# Download RABBIT
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Run local server
python -m http.server 8000

# Open in browser: http://localhost:8000
```

**Don't have Python?** Download from [python.org](https://python.org)

---

### Option 2: Without Git

1. **Download ZIP**
   - Go to: https://github.com/michaelrobgrove/RABBIT
   - Click "Code" → "Download ZIP"
   - Extract the ZIP file

2. **Open Terminal/Command Prompt**
   - **Windows**: Press `Win + R`, type `cmd`, press Enter
   - **Mac**: Press `Cmd + Space`, type `terminal`, press Enter
   - **Linux**: Press `Ctrl + Alt + T`

3. **Navigate to folder**
   ```bash
   cd path/to/RABBIT
   ```

4. **Start Server**
   ```bash
   # Python 3 (recommended)
   python -m http.server 8000
   
   # OR Python 2
   python -m SimpleHTTPServer 8000
   ```

5. **Open Browser**
   - Go to: `http://localhost:8000`
   - Done! ✅

---

## Alternative Methods

### Using Node.js

```bash
# Install http-server globally
npm install -g http-server

# Run in RABBIT directory
http-server -p 8000

# Open: http://localhost:8000
```

### Using PHP

```bash
# Run in RABBIT directory
php -S localhost:8000

# Open: http://localhost:8000
```

### Using Browser Extension (Chrome/Edge)

1. Install "Web Server for Chrome" extension
2. Choose RABBIT folder
3. Click web server URL
4. Done!

---

## 📱 Access from Other Devices

Want to use RABBIT on your phone/tablet on the same WiFi?

1. **Find Your Computer's IP**
   - **Windows**: `ipconfig` → Look for "IPv4 Address"
   - **Mac/Linux**: `ifconfig` or `ip addr` → Look for "inet"
   - Usually looks like: `192.168.1.x`

2. **Start RABBIT** (as above)

3. **On Other Device**
   - Open browser
   - Go to: `http://YOUR_IP:8000`
   - Example: `http://192.168.1.100:8000`

---

## 🔒 Security Note

Running a local web server is safe when:
- ✅ Only accessible on your local network
- ✅ Not exposed to the internet
- ✅ Firewall is enabled

**Don't**:
- ❌ Port forward to the internet
- ❌ Disable your firewall
- ❌ Share your IP publicly

---

## ✅ Benefits of Running Locally

1. **HTTP Support** - Works with any IPTV service (HTTP or HTTPS)
2. **No CORS Issues** - Direct access to streams
3. **Full Privacy** - Everything stays on your device
4. **Offline Ready** - No internet needed (except for streams)
5. **Faster** - No external server latency
6. **Free** - No hosting costs

---

## 🛠️ Troubleshooting

### "python: command not found"
**Solution**: Install Python from [python.org](https://python.org)

### Port 8000 already in use
**Solution**: Use a different port:
```bash
python -m http.server 9000
# Then open: http://localhost:9000
```

### Can't access from phone
**Solutions**:
1. Check both devices on same WiFi
2. Disable firewall temporarily to test
3. Try `http://0.0.0.0:8000` instead

### Server stops when closing terminal
**Solutions**:

**Mac/Linux**:
```bash
nohup python -m http.server 8000 &
```

**Windows**: Leave Command Prompt window open

---

## 🎯 Make it Easier

### Create Desktop Shortcut

**Windows** (create `start-rabbit.bat`):
```batch
@echo off
cd C:\path\to\RABBIT
python -m http.server 8000
pause
```

**Mac** (create `start-rabbit.command`):
```bash
#!/bin/bash
cd ~/path/to/RABBIT
python -m http.server 8000
```
Then: `chmod +x start-rabbit.command`

**Linux** (create `start-rabbit.sh`):
```bash
#!/bin/bash
cd ~/path/to/RABBIT
python -m http.server 8000
```
Then: `chmod +x start-rabbit.sh`

### Create System Service (Advanced)

For always-on access, create a systemd service (Linux) or Windows service.

See [DEPLOYMENT.md](DEPLOYMENT.md) for advanced setups.

---

## 📊 When to Use Which Version?

| Scenario | Use This |
|----------|----------|
| HTTP IPTV service | **Local (this guide)** ✅ |
| HTTPS IPTV service | Either (cloud or local) |
| Mobile/tablet access | Local + IP address |
| Quick test | Cloud (rabbit-30m.pages.dev) |
| Best privacy | Local ✅ |
| Access from anywhere | Cloud |
| Multiple devices at home | Local + IP address ✅ |

---

## 🆘 Still Need Help?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Open issue: [GitHub Issues](https://github.com/michaelrobgrove/RABBIT/issues)
3. Ask in: [GitHub Discussions](https://github.com/michaelrobgrove/RABBIT/discussions)

---

## 🎉 You're All Set!

RABBIT is now running locally and can handle any IPTV service!

**Remember**:
- Keep terminal window open while using
- Use `http://localhost:8000` (not https)
- Stop server: Press `Ctrl + C` in terminal

---

**Quick Reference Card**:
```
1. cd RABBIT
2. python -m http.server 8000
3. Open: http://localhost:8000
4. Stop: Ctrl + C
```

That's it! Enjoy RABBIT! 🐰📺
