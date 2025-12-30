# RABBIT Self-Hosting - Complete Guide

Run RABBIT locally on your computer for the best experience! Works with ALL IPTV services (HTTP and HTTPS).

---

## 🚀 Choose Your Platform:

- [Windows](#windows-setup) - One-click installer
- [Ubuntu/Debian Linux](#ubuntudebian-linux) - One command setup
- [macOS](#macos-setup) - Simple Terminal commands
- [Docker](#docker-setup) - Container deployment

---

## Windows Setup

### Method 1: One-Click Installer (Easiest)

1. **Download RABBIT**
   - Go to: https://github.com/michaelrobgrove/RABBIT
   - Click "Code" → "Download ZIP"
   - Extract to `C:\RABBIT`

2. **Download Python** (if you don't have it)
   - Visit: https://python.org/downloads
   - Download Python 3.11 or newer
   - **IMPORTANT**: Check "Add Python to PATH" during installation

3. **Create Start Script**
   
   Create a file called `start-rabbit.bat` in the RABBIT folder:
   
   ```batch
   @echo off
   title RABBIT IPTV Player
   color 0A
   
   echo.
   echo  ====================================
   echo   🐰 RABBIT IPTV Player
   echo  ====================================
   echo.
   echo  Starting server...
   echo.
   
   cd /d "%~dp0"
   
   REM Check if Python is installed
   python --version >nul 2>&1
   if errorlevel 1 (
       echo ERROR: Python is not installed or not in PATH
       echo Please install Python from python.org
       pause
       exit /b 1
   )
   
   echo  ✓ Python found
   echo.
   echo  Server running at:
   echo  ┌────────────────────────────────┐
   echo  │  http://localhost:8000         │
   echo  └────────────────────────────────┘
   echo.
   echo  Press Ctrl+C to stop the server
   echo.
   
   python -m http.server 8000
   
   pause
   ```

4. **Double-Click `start-rabbit.bat`**
   - Opens a command window
   - Shows the URL: `http://localhost:8000`
   - Open that URL in your browser
   - Done! ✅

5. **Create Desktop Shortcut** (Optional)
   - Right-click `start-rabbit.bat`
   - Send to → Desktop (create shortcut)
   - Rename to "RABBIT IPTV"
   - Right-click shortcut → Properties → Change Icon
   - Choose an icon or use `images/rabbit.svg`

### Method 2: Windows Service (Always Running)

For advanced users who want RABBIT to start automatically:

1. **Download NSSM** (Non-Sucking Service Manager)
   - Visit: https://nssm.cc/download
   - Extract `nssm.exe` to `C:\RABBIT`

2. **Install as Service**
   
   Open PowerShell as Administrator:
   ```powershell
   cd C:\RABBIT
   .\nssm.exe install RABBIT "C:\Python311\python.exe" "-m http.server 8000"
   .\nssm.exe set RABBIT AppDirectory C:\RABBIT
   .\nssm.exe set RABBIT DisplayName "RABBIT IPTV Player"
   .\nssm.exe set RABBIT Description "Local IPTV player web server"
   .\nssm.exe start RABBIT
   ```

3. **Manage Service**
   - Start: `.\nssm.exe start RABBIT`
   - Stop: `.\nssm.exe stop RABBIT`
   - Remove: `.\nssm.exe remove RABBIT confirm`

### Method 3: Using Node.js (Alternative)

If you prefer Node.js over Python:

1. **Install Node.js**
   - Download from: https://nodejs.org
   - Install LTS version

2. **Create `start-rabbit.js`**
   ```javascript
   const http = require('http');
   const fs = require('fs');
   const path = require('path');
   
   const PORT = 8000;
   
   const mimeTypes = {
     '.html': 'text/html',
     '.css': 'text/css',
     '.js': 'text/javascript',
     '.json': 'application/json',
     '.png': 'image/png',
     '.jpg': 'image/jpeg',
     '.svg': 'image/svg+xml',
     '.m3u': 'application/x-mpegurl',
     '.m3u8': 'application/vnd.apple.mpegurl'
   };
   
   const server = http.createServer((req, res) => {
     let filePath = '.' + req.url;
     if (filePath === './') filePath = './index.html';
     
     const extname = String(path.extname(filePath)).toLowerCase();
     const contentType = mimeTypes[extname] || 'application/octet-stream';
     
     fs.readFile(filePath, (err, content) => {
       if (err) {
         if (err.code === 'ENOENT') {
           res.writeHead(404, { 'Content-Type': 'text/html' });
           res.end('<h1>404 Not Found</h1>', 'utf-8');
         } else {
           res.writeHead(500);
           res.end('Server Error: ' + err.code, 'utf-8');
         }
       } else {
         res.writeHead(200, { 'Content-Type': contentType });
         res.end(content, 'utf-8');
       }
     });
   });
   
   server.listen(PORT, '127.0.0.1', () => {
     console.log('🐰 RABBIT IPTV Player running at:');
     console.log(`   http://localhost:${PORT}`);
     console.log('\nPress Ctrl+C to stop');
   });
   ```

3. **Run**
   ```batch
   node start-rabbit.js
   ```

---

## Ubuntu/Debian Linux

### One-Command Setup

Create an installation script `install-rabbit.sh`:

```bash
#!/bin/bash

# RABBIT IPTV Player - Ubuntu/Debian Installer
# Run: curl -fsSL https://raw.githubusercontent.com/michaelrobgrove/RABBIT/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/rabbit-iptv"
SERVICE_NAME="rabbit-iptv"

echo "🐰 RABBIT IPTV Player - Installer"
echo "=================================="
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "Installing Python..."
    sudo apt-get update
    sudo apt-get install -y python3
fi

# Download RABBIT
echo "📦 Downloading RABBIT..."
if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  RABBIT already exists at $INSTALL_DIR"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
    rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Clone or download
if command -v git &> /dev/null; then
    git clone https://github.com/michaelrobgrove/RABBIT.git .
else
    echo "Git not found, downloading ZIP..."
    sudo apt-get install -y wget unzip
    wget https://github.com/michaelrobgrove/RABBIT/archive/refs/heads/main.zip
    unzip main.zip
    mv RABBIT-main/* .
    rm -rf RABBIT-main main.zip
fi

echo "✅ Downloaded to $INSTALL_DIR"

# Create startup script
cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "🐰 RABBIT IPTV Player"
echo "===================="
echo ""
echo "Server running at: http://localhost:8000"
echo "Press Ctrl+C to stop"
echo ""
python3 -m http.server 8000
EOF

chmod +x start.sh

# Create systemd service
echo ""
read -p "Install as system service (starts on boot)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=RABBIT IPTV Player
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 -m http.server 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    
    echo "✅ Service installed and started"
    echo ""
    echo "Manage service:"
    echo "  Start:   sudo systemctl start $SERVICE_NAME"
    echo "  Stop:    sudo systemctl stop $SERVICE_NAME"
    echo "  Status:  sudo systemctl status $SERVICE_NAME"
    echo "  Logs:    sudo journalctl -u $SERVICE_NAME -f"
fi

echo ""
echo "=================================="
echo "✅ Installation Complete!"
echo "=================================="
echo ""
echo "🚀 To start manually:"
echo "   cd $INSTALL_DIR"
echo "   ./start.sh"
echo ""
echo "🌐 Open in browser:"
echo "   http://localhost:8000"
echo ""
echo "📱 Access from other devices:"
echo "   1. Find your IP: ip addr"
echo "   2. Open: http://YOUR_IP:8000"
echo ""
echo "🎉 Enjoy RABBIT!"
```

### Quick Install

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/michaelrobgrove/RABBIT/main/install.sh | bash

# Or manually:
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT
python3 -m http.server 8000
```

### Create Desktop Entry (Ubuntu Desktop)

```bash
# Create .desktop file
cat > ~/.local/share/applications/rabbit-iptv.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=RABBIT IPTV Player
Comment=Free open-source IPTV player
Exec=bash -c "cd $HOME/rabbit-iptv && ./start.sh"
Icon=$HOME/rabbit-iptv/images/rabbit.svg
Terminal=true
Categories=AudioVideo;Video;Player;
EOF

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

Now RABBIT appears in your applications menu!

---

## macOS Setup

### Simple Method

```bash
# Install using Homebrew (if you have it)
brew install python3

# Clone RABBIT
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Start server
python3 -m http.server 8000

# Open browser
open http://localhost:8000
```

### Create macOS App

1. **Create `start-rabbit.command`**
   
   ```bash
   #!/bin/bash
   cd "$(dirname "$0")"
   
   echo "🐰 RABBIT IPTV Player"
   echo "===================="
   echo ""
   echo "Server running at: http://localhost:8000"
   echo ""
   
   python3 -m http.server 8000
   ```

2. **Make it executable**
   ```bash
   chmod +x start-rabbit.command
   ```

3. **Double-click to run!**

### Create macOS Menu Bar App (Advanced)

Create `RABBIT.app` using Automator:

1. Open **Automator**
2. Create new **Application**
3. Add **Run Shell Script** action
4. Paste:
   ```bash
   cd ~/rabbit-iptv
   python3 -m http.server 8000 &
   sleep 2
   open http://localhost:8000
   ```
5. Save as `RABBIT.app`
6. Drag to Applications folder

---

## Docker Setup

Perfect for any platform!

### Create `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy RABBIT files
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000')"

# Run server
CMD ["python3", "-m", "http.server", "8000"]
```

### Create `docker-compose.yml`

```yaml
version: '3.8'

services:
  rabbit:
    build: .
    container_name: rabbit-iptv
    ports:
      - "8000:8000"
    restart: unless-stopped
    volumes:
      - ./:/app:ro
    healthcheck:
      test: ["CMD", "python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000')"]
      interval: 30s
      timeout: 3s
      retries: 3
```

### Run with Docker

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Or without docker-compose:
docker build -t rabbit-iptv .
docker run -d -p 8000:8000 --name rabbit rabbit-iptv
```

---

## 🌐 Access from Mobile Devices

Once RABBIT is running on your computer, access it from your phone/tablet:

### Find Your Computer's IP

**Windows**:
```batch
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.1.100)

**Linux/macOS**:
```bash
ip addr  # or: ifconfig
```
Look for "inet" (e.g., 192.168.1.100)

### Open on Mobile

On your phone/tablet (connected to same WiFi):
```
http://YOUR_COMPUTER_IP:8000
```

Example: `http://192.168.1.100:8000`

---

## 🔧 Troubleshooting

### Port 8000 Already in Use

Use a different port:
```bash
python3 -m http.server 9000
# Then open: http://localhost:9000
```

### Firewall Blocking Access

**Windows**:
```powershell
# Run as Administrator
netsh advfirewall firewall add rule name="RABBIT IPTV" dir=in action=allow protocol=TCP localport=8000
```

**Linux**:
```bash
sudo ufw allow 8000/tcp
```

**macOS**:
System Preferences → Security & Privacy → Firewall → Firewall Options → Add python3

### Python Not Found

**Windows**: Reinstall Python with "Add to PATH" checked

**Linux**: `sudo apt-get install python3`

**macOS**: `brew install python3`

---

## 🎯 Pro Tips

### Use a Custom Port
```bash
python3 -m http.server 3000
```

### Bind to All Interfaces (Access from Network)
```bash
python3 -m http.server 8000 --bind 0.0.0.0
```

### Use HTTPS Locally
```bash
# Generate certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Run with HTTPS
python3 -m http.server 8000 --bind localhost --protocol HTTPS
```

---

## 📊 Comparison

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| Python | Simple, built-in | Basic features | Everyone |
| Node.js | More control | Requires Node | Developers |
| Docker | Isolated, portable | Requires Docker | Servers |
| System Service | Auto-start | Harder setup | Always-on |

---

## 🆘 Need Help?

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [GitHub Issues](https://github.com/michaelrobgrove/RABBIT/issues)
- [Discussions](https://github.com/michaelrobgrove/RABBIT/discussions)

---

## ✅ Quick Reference

```bash
# Clone
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Run
python3 -m http.server 8000

# Open
http://localhost:8000

# Stop
Ctrl + C
```

That's it! 🐰🎉
