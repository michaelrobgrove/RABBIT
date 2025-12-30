#!/bin/bash

# RABBIT Proxy Update Script
# Fixes CORS and User-Agent forwarding
# Run as root: sudo bash proxy_update.sh

set -e

echo "🐰 RABBIT Proxy Updater"
echo "======================="

if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Please run as root"
    exit 1
fi

PROXY_DIR="/opt/rabbit-proxy"
SERVER_FILE="${PROXY_DIR}/server.js"

echo "📍 Target Directory: ${PROXY_DIR}"

if [ ! -d "$PROXY_DIR" ]; then
    echo "❌ Error: Proxy directory not found at ${PROXY_DIR}"
    echo "   Is the proxy installed?"
    exit 1
fi

# Backup existing server.js
if [ -f "$SERVER_FILE" ]; then
    echo "📦 Backing up old server.js..."
    cp "$SERVER_FILE" "${SERVER_FILE}.bak.$(date +%s)"
fi

# Write new server.js
echo "📝 Writing new server.js..."
cat > "$SERVER_FILE" << 'EOF'
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 3000;

// Security headers
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false
}));

// CORS Configuration - CRITICAL FIX
app.use(cors({
  origin: '*', // Allow ALL origins (required for direct browser access)
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-User-Agent'], // Allow our custom header
  credentials: true
}));

// Rate limiting (generous for video)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000, // Increased limit for video segments
  message: { error: 'Too many requests' }
});
app.use(limiter);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'RABBIT Proxy v1.1' });
});

// MAIN PROXY HANDLER
app.get('/proxy', async (req, res) => {
  const targetUrl = req.query.url;
  
  // Custom User-Agent handling
  // If RABBIT sends 'X-User-Agent', use it. Otherwise default to Smarters.
  const customAgent = req.headers['x-user-agent'] || 'IPTVSmartersPro';

  if (!targetUrl) return res.status(400).json({ error: 'Missing url' });

  try {
    const response = await axios({
      method: 'GET',
      url: targetUrl,
      responseType: 'stream', // Stream directly for performance
      timeout: 30000,
      headers: {
        'User-Agent': customAgent,
        'Accept': '*/*'
      },
      // SSL bypass for some shady IPTV providers
      httpsAgent: new (require('https').Agent)({ rejectUnauthorized: false })
    });

    // Forward important headers
    if(response.headers['content-type']) res.setHeader('Content-Type', response.headers['content-type']);
    if(response.headers['content-length']) res.setHeader('Content-Length', response.headers['content-length']);

    // Ensure CORS headers are explicit on response
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    // Pipe data
    response.data.pipe(res);

  } catch (error) {
    console.error(`Proxy Error [${targetUrl}]:`, error.message);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Proxy failed', details: error.message });
    }
  }
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`🐰 Proxy running on port ${PORT}`);
});
EOF

echo "🔄 Restarting service..."
systemctl restart rabbit-proxy

echo "✅ Update Complete!"
echo "   Test with: curl -I https://ether.tfplus.stream/health"
