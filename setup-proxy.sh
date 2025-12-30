#!/bin/bash

# RABBIT CORS Proxy - Automated Setup Script
# Run on Ubuntu 20.04/22.04/24.04

set -e

echo "🐰 RABBIT CORS Proxy - Automated Setup"
echo "======================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Please run as root: sudo bash setup.sh"
    exit 1
fi

# Get user inputs
read -p "Enter your domain for the proxy (e.g., proxy.yourdomain.com): " DOMAIN
read -p "Enter your RABBIT site URL (e.g., https://rabbit-30m.pages.dev): " RABBIT_URL
read -p "Choose setup method (1=Cloudflare Tunnel, 2=Nginx+Let's Encrypt): " SETUP_METHOD

echo ""
echo "📦 Installing dependencies..."

# Update system
apt-get update -qq

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi

echo "✅ Node.js $(node --version) installed"

# Create proxy directory
PROXY_DIR="/opt/rabbit-proxy"
mkdir -p $PROXY_DIR
cd $PROXY_DIR

# Create package.json
cat > package.json << EOF
{
  "name": "rabbit-proxy",
  "version": "1.0.0",
  "description": "CORS proxy for RABBIT IPTV",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "axios": "^1.6.0",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5"
  }
}
EOF

# Install npm packages
echo "📦 Installing Node.js packages..."
npm install --silent

# Create server.js
cat > server.js << 'SERVERJS'
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { error: 'Too many requests, please try again later.' }
});

app.use(limiter);

// Security
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginResourcePolicy: false
}));

// CORS
app.use(cors({
  origin: function(origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = process.env.ALLOWED_ORIGINS 
      ? process.env.ALLOWED_ORIGINS.split(',')
      : ['*'];
    
    if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'RABBIT CORS Proxy',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

// Main proxy endpoint
app.get('/proxy', async (req, res) => {
  const targetUrl = req.query.url;

  if (!targetUrl) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  try {
    new URL(targetUrl);
  } catch (e) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  try {
    const response = await axios({
      method: 'GET',
      url: targetUrl,
      responseType: 'arraybuffer',
      timeout: 30000,
      maxRedirects: 5,
      headers: {
        'User-Agent': 'RABBIT-Proxy/1.0',
      }
    });

    // Forward headers
    const headersToForward = ['content-type', 'content-length', 'cache-control'];
    headersToForward.forEach(header => {
      if (response.headers[header]) {
        res.setHeader(header, response.headers[header]);
      }
    });

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(response.status).send(response.data);

  } catch (error) {
    console.error('Proxy error:', error.message);
    res.status(error.response?.status || 500).json({
      error: 'Proxy request failed',
      message: error.message
    });
  }
});

// M3U proxy
app.get('/m3u', async (req, res) => {
  const targetUrl = req.query.url;

  if (!targetUrl) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  try {
    const response = await axios.get(targetUrl, {
      responseType: 'text',
      timeout: 30000
    });

    res.setHeader('Content-Type', 'application/x-mpegurl');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.send(response.data);

  } catch (error) {
    console.error('M3U error:', error.message);
    res.status(500).json({ error: 'Failed to fetch M3U', message: error.message });
  }
});

// Stream proxy
app.get('/stream', async (req, res) => {
  const targetUrl = req.query.url;

  if (!targetUrl) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  try {
    const response = await axios({
      method: 'GET',
      url: targetUrl,
      responseType: 'stream',
      timeout: 60000
    });

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', response.headers['content-type'] || 'application/octet-stream');
    
    response.data.pipe(res);

  } catch (error) {
    console.error('Stream error:', error.message);
    res.status(500).json({ error: 'Stream failed', message: error.message });
  }
});

// Start server
const server = app.listen(PORT, '127.0.0.1', () => {
  console.log(`🐰 RABBIT CORS Proxy running on port ${PORT}`);
  console.log(`Allowed origins: ${process.env.ALLOWED_ORIGINS || '*'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
SERVERJS

# Create environment file
cat > .env << EOF
PORT=3000
ALLOWED_ORIGINS=${RABBIT_URL},http://localhost:8000
EOF

# Create systemd service
cat > /etc/systemd/system/rabbit-proxy.service << EOF
[Unit]
Description=RABBIT CORS Proxy
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${PROXY_DIR}
EnvironmentFile=${PROXY_DIR}/.env
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable rabbit-proxy
systemctl start rabbit-proxy

echo "✅ Proxy service installed and started"

# Setup based on method
if [ "$SETUP_METHOD" == "1" ]; then
    echo ""
    echo "📡 Setting up Cloudflare Tunnel..."
    
    # Install cloudflared
    if ! command -v cloudflared &> /dev/null; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
        dpkg -i cloudflared-linux-amd64.deb
        rm cloudflared-linux-amd64.deb
    fi
    
    echo ""
    echo "🔐 Please authenticate with Cloudflare..."
    echo "A browser window will open. Please login and select your domain."
    echo ""
    cloudflared tunnel login
    
    echo ""
    read -p "Enter a name for your tunnel (e.g., rabbit-proxy): " TUNNEL_NAME
    
    # Create tunnel
    cloudflared tunnel create $TUNNEL_NAME
    
    # Get tunnel ID
    TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
    
    echo "Tunnel ID: $TUNNEL_ID"
    
    # Create config
    mkdir -p /etc/cloudflared
    cat > /etc/cloudflared/config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: ${DOMAIN}
    service: http://localhost:3000
  - service: http_status:404
EOF
    
    # Route DNS
    cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN
    
    # Install as service
    cloudflared service install
    systemctl start cloudflared
    systemctl enable cloudflared
    
    echo ""
    echo "✅ Cloudflare Tunnel configured!"
    
elif [ "$SETUP_METHOD" == "2" ]; then
    echo ""
    echo "🌐 Setting up Nginx with Let's Encrypt..."
    
    # Install Nginx
    apt-get install -y nginx certbot python3-certbot-nginx
    
    # Create Nginx config
    cat > /etc/nginx/sites-available/rabbit-proxy << EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    
    # Enable site
    ln -sf /etc/nginx/sites-available/rabbit-proxy /etc/nginx/sites-enabled/
    nginx -t
    systemctl restart nginx
    
    # Get SSL certificate
    echo ""
    echo "🔒 Obtaining SSL certificate..."
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --register-unsafely-without-email
    
    echo "✅ Nginx and SSL configured!"
else
    echo "Invalid setup method"
    exit 1
fi

echo ""
echo "========================================="
echo "✅ RABBIT CORS Proxy Setup Complete!"
echo "========================================="
echo ""
echo "📍 Your proxy is available at:"
echo "   https://${DOMAIN}/health"
echo ""
echo "🧪 Test it:"
echo "   curl https://${DOMAIN}/health"
echo ""
echo "🔧 Update RABBIT to use your proxy:"
echo "   Change corsProxy to: 'https://${DOMAIN}/proxy?url='"
echo ""
echo "📊 Monitor logs:"
echo "   sudo journalctl -u rabbit-proxy -f"
if [ "$SETUP_METHOD" == "1" ]; then
    echo "   sudo journalctl -u cloudflared -f"
fi
echo ""
echo "🎉 Done! Your $5 server is now a CORS proxy for RABBIT!"
