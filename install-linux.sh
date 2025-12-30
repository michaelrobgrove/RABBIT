#!/bin/bash

# RABBIT IPTV Player - Linux Installer
# Supports: Ubuntu, Debian, Fedora, Arch, and derivatives
# Run: curl -fsSL https://raw.githubusercontent.com/michaelrobgrove/RABBIT/main/install-linux.sh | bash

set -e

INSTALL_DIR="$HOME/rabbit-iptv"
SERVICE_NAME="rabbit-iptv"
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "🐰 RABBIT IPTV Player - Linux Installer"
echo "========================================"
echo ""

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}Cannot detect Linux distribution${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected: $PRETTY_NAME"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Installing Python...${NC}"
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get update -qq
            sudo apt-get install -y python3 python3-pip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y python3 python3-pip
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm python python-pip
            ;;
        *)
            echo -e "${RED}Unsupported distribution. Please install Python manually.${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✓${NC} Python installed"
else
    echo -e "${GREEN}✓${NC} Python found: $(python3 --version)"
fi

echo ""

# Download RABBIT
echo "📦 Downloading RABBIT..."

if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  RABBIT already exists at $INSTALL_DIR${NC}"
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
    git clone -q https://github.com/michaelrobgrove/RABBIT.git .
    echo -e "${GREEN}✓${NC} Cloned from GitHub"
else
    echo -e "${YELLOW}Git not found, downloading ZIP...${NC}"
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get install -y wget unzip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y wget unzip
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm wget unzip
            ;;
    esac
    
    wget -q https://github.com/michaelrobgrove/RABBIT/archive/refs/heads/main.zip
    unzip -q main.zip
    mv RABBIT-main/* .
    rm -rf RABBIT-main main.zip
    echo -e "${GREEN}✓${NC} Downloaded from GitHub"
fi

echo -e "${GREEN}✓${NC} Installed to $INSTALL_DIR"
echo ""

# Create startup script
cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo ""
echo -e "${GREEN}🐰 RABBIT IPTV Player${NC}"
echo "===================="
echo ""
echo -e "Server running at: ${BLUE}http://localhost:8000${NC}"
echo ""
echo "Open the URL above in your browser"
echo "Press Ctrl+C to stop"
echo ""

python3 -m http.server 8000
EOF

chmod +x start.sh

# Create systemd service
echo ""
read -p "Install as system service (starts on boot)? (y/n) " -n 1 -r
echo ""

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
    
    echo -e "${GREEN}✓${NC} Service installed and started"
    echo ""
    echo "Service commands:"
    echo "  Start:   sudo systemctl start $SERVICE_NAME"
    echo "  Stop:    sudo systemctl stop $SERVICE_NAME"
    echo "  Restart: sudo systemctl restart $SERVICE_NAME"
    echo "  Status:  sudo systemctl status $SERVICE_NAME"
    echo "  Logs:    sudo journalctl -u $SERVICE_NAME -f"
fi

# Create desktop entry for GUI systems
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo ""
    read -p "Create application menu entry? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.local/share/applications
        
        cat > ~/.local/share/applications/rabbit-iptv.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=RABBIT IPTV Player
Comment=Free open-source IPTV player
Exec=bash -c "cd $INSTALL_DIR && ./start.sh"
Icon=$INSTALL_DIR/images/rabbit.svg
Terminal=true
Categories=AudioVideo;Video;Player;Network;
Keywords=IPTV;streaming;media;player;
EOF
        
        # Update desktop database
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓${NC} Menu entry created"
        echo "  Look for 'RABBIT IPTV Player' in your applications menu"
    fi
fi

# Get local IP for network access
LOCAL_IP=$(ip route get 1 | awk '{print $7;exit}' 2>/dev/null || echo "127.0.0.1")

echo ""
echo "========================================"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo "========================================"
echo ""
echo "🚀 To start RABBIT:"
echo "   cd $INSTALL_DIR"
echo "   ./start.sh"
echo ""
echo "🌐 Access URLs:"
echo "   Local:   http://localhost:8000"
echo "   Network: http://$LOCAL_IP:8000"
echo ""
echo "📱 Access from other devices:"
echo "   Open: http://$LOCAL_IP:8000"
echo "   (on devices connected to same WiFi)"
echo ""
echo "📚 Documentation:"
echo "   README: $INSTALL_DIR/README.md"
echo "   Troubleshooting: $INSTALL_DIR/TROUBLESHOOTING.md"
echo ""
echo "🆘 Need help?"
echo "   GitHub: https://github.com/michaelrobgrove/RABBIT/issues"
echo ""
echo "🎉 Enjoy RABBIT!"
echo ""
