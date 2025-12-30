# RABBIT CORS Proxy Server with Cloudflare Tunnel

## 🎯 The Perfect Solution

Use your Ubuntu server as an HTTPS proxy that bridges HTTP IPTV services to your HTTPS RABBIT site!

**How it works**:
```
RABBIT (HTTPS) → CF Tunnel (HTTPS) → Your Server → IPTV Service (HTTP)
      ✅                ✅              🔄            ❌
```

Your server accepts HTTPS requests and forwards them to HTTP IPTV services, solving the mixed content problem!

---

## 🚀 Quick Setup (15 minutes)

### Prerequisites
- Ubuntu server with public IP or domain
- Root/sudo access
- Port 80 and 443 available (or use Cloudflare Tunnel)

---

## Option 1: Cloudflare Tunnel (Recommended - No Port Forwarding!)

### Step 1: Install Cloudflare Tunnel

```bash
# SSH into your server
ssh user@your-server

# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Install it
sudo dpkg -i cloudflared-linux-amd64.deb

# Authenticate with Cloudflare
cloudflared tunnel login
# This opens a browser - select your domain
```

### Step 2: Create the Tunnel

```bash
# Create tunnel
cloudflared tunnel create rabbit-proxy

# Note the Tunnel ID shown (looks like: 12345678-1234-1234-1234-123456789abc)

# Create config directory
sudo mkdir -p /etc/cloudflared

# Create config file
sudo nano /etc/cloudflared/config.yml
```

### Step 3: Configure Tunnel

Paste this into `/etc/cloudflared/config.yml`:

```yaml
tunnel: YOUR_TUNNEL_ID_HERE
credentials-file: /root/.cloudflared/YOUR_TUNNEL_ID_HERE.json

ingress:
  - hostname: proxy.yourdomain.com
    service: http://localhost:3000
  - service: http_status:404
```

Replace:
- `YOUR_TUNNEL_ID_HERE` with your actual tunnel ID
- `proxy.yourdomain.com` with your subdomain

### Step 4: Configure DNS

```bash
# Add DNS record
cloudflared tunnel route dns rabbit-proxy proxy.yourdomain.com
```

### Step 5: Install Node.js Proxy Server

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create directory
mkdir ~/rabbit-proxy
cd ~/rabbit-proxy

# Create package.json
cat > package.json << 'EOF'
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
    "helmet": "^7.1.0"
  }
}
EOF

# Install dependencies
npm install
```

### Step 6: Create Proxy Server

```bash
nano server.js
```

Paste this code:

```javascript
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const helmet = require('helmet');

const app = express();
const PORT = 3000;

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
}));

// CORS configuration - allow your RABBIT domain
app.use(cors({
  origin: [
    'https://rabbit-30m.pages.dev',
    'https://your-custom-domain.com',
    'http://localhost:8000' // for local testing
  ],
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'RABBIT CORS Proxy' });
});

// Main proxy endpoint
app.get('/proxy', async (req, res) => {
  const targetUrl = req.query.url;

  if (!targetUrl) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  // Validate URL
  try {
    new URL(targetUrl);
  } catch (e) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  console.log(`Proxying request to: ${targetUrl}`);

  try {
    // Make request to target (supports HTTP)
    const response = await axios({
      method: 'GET',
      url: targetUrl,
      responseType: 'arraybuffer',
      timeout: 30000,
      maxRedirects: 5,
      headers: {
        'User-Agent': 'RABBIT-Proxy/1.0',
      },
      // Important: Allow HTTP
      httpsAgent: undefined,
      httpAgent: undefined,
    });

    // Forward response headers
    Object.keys(response.headers).forEach(key => {
      res.setHeader(key, response.headers[key]);
    });

    // Add CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    
    // Send response
    res.status(response.status).send(response.data);

  } catch (error) {
    console.error('Proxy error:', error.message);
    
    if (error.response) {
      res.status(error.response.status).json({
        error: 'Proxy request failed',
        status: error.response.status,
        message: error.message
      });
    } else {
      res.status(500).json({
        error: 'Proxy request failed',
        message: error.message
      });
    }
  }
});

// M3U proxy endpoint (returns text)
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
    console.error('M3U proxy error:', error.message);
    res.status(500).json({ error: 'Failed to fetch M3U', message: error.message });
  }
});

// Stream proxy endpoint (for HLS/video streams)
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
      timeout: 30000
    });

    // Forward headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', response.headers['content-type'] || 'application/octet-stream');
    
    // Pipe stream
    response.data.pipe(res);

  } catch (error) {
    console.error('Stream proxy error:', error.message);
    res.status(500).json({ error: 'Stream failed', message: error.message });
  }
});

// Start server
app.listen(PORT, '127.0.0.1', () => {
  console.log(`🐰 RABBIT CORS Proxy running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
```

### Step 7: Test the Server

```bash
# Start the proxy
node server.js

# In another terminal, test it
curl http://localhost:3000/health
# Should return: {"status":"ok","service":"RABBIT CORS Proxy"}
```

### Step 8: Setup as System Service

```bash
# Create service file
sudo nano /etc/systemd/system/rabbit-proxy.service
```

Paste:

```ini
[Unit]
Description=RABBIT CORS Proxy
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/rabbit-proxy
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable rabbit-proxy
sudo systemctl start rabbit-proxy
sudo systemctl status rabbit-proxy
```

### Step 9: Start Cloudflare Tunnel

```bash
# Test tunnel
cloudflared tunnel run rabbit-proxy

# If it works, install as service
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

### Step 10: Test Your Proxy

```bash
# Test from your local machine
curl https://proxy.yourdomain.com/health

# Test proxying (replace with a real HTTP IPTV URL)
curl "https://proxy.yourdomain.com/proxy?url=http://example.com/playlist.m3u"
```

---

## Option 2: Traditional Reverse Proxy (Nginx + Let's Encrypt)

If you prefer not to use Cloudflare Tunnel:

### Setup Nginx

```bash
# Install Nginx
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# Configure Nginx
sudo nano /etc/nginx/sites-available/rabbit-proxy
```

Paste:

```nginx
server {
    listen 80;
    server_name proxy.yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable and get SSL:

```bash
sudo ln -s /etc/nginx/sites-available/rabbit-proxy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d proxy.yourdomain.com
```

---

## 🔧 Update RABBIT to Use Your Proxy

Now update your RABBIT `index.html` to use your proxy:

### Find this line (around line 1043):
```javascript
const corsProxy = 'https://corsproxy.io/?';
```

### Change to:
```javascript
const corsProxy = 'https://proxy.yourdomain.com/proxy?url=';
```

### Or make it configurable:
```javascript
// Use your proxy first, fallback to public proxy
const corsProxies = [
    'https://proxy.yourdomain.com/proxy?url=',
    'https://corsproxy.io/?',
    'https://api.allorigins.win/raw?url='
];
```

---

## 🎯 Usage in RABBIT

Users can now use HTTP IPTV services on your HTTPS RABBIT site!

### For M3U:
```
Original URL: http://iptv-provider.com/playlist.m3u
Proxied URL: https://proxy.yourdomain.com/m3u?url=http://iptv-provider.com/playlist.m3u
```

### For Streams:
```
Original URL: http://iptv-provider.com/stream.m3u8
Proxied URL: https://proxy.yourdomain.com/stream?url=http://iptv-provider.com/stream.m3u8
```

RABBIT will automatically use your proxy for HTTP URLs!

---

## 🔒 Security Considerations

### Rate Limiting (Recommended)

Install express-rate-limit:

```bash
cd ~/rabbit-proxy
npm install express-rate-limit
```

Add to `server.js`:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use(limiter);
```

### Restrict Origins

Update CORS config to only allow your domain:

```javascript
app.use(cors({
  origin: ['https://rabbit-30m.pages.dev'], // Only your domain
  credentials: true
}));
```

### Add Authentication (Optional)

```javascript
const AUTH_TOKEN = 'your-secret-token-here';

app.use((req, res, next) => {
  const token = req.headers.authorization;
  if (token !== `Bearer ${AUTH_TOKEN}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});
```

---

## 📊 Monitoring

### Check Logs

```bash
# Proxy logs
sudo journalctl -u rabbit-proxy -f

# Cloudflare Tunnel logs
sudo journalctl -u cloudflared -f

# Nginx logs (if using)
sudo tail -f /var/log/nginx/access.log
```

### Monitor Resources

```bash
# Check server resources
htop

# Check proxy status
curl https://proxy.yourdomain.com/health
```

---

## 🚀 Advanced: Load Balancing

If you get lots of traffic, add multiple proxy servers:

```javascript
const proxyServers = [
  'https://proxy1.yourdomain.com/proxy?url=',
  'https://proxy2.yourdomain.com/proxy?url=',
  'https://proxy3.yourdomain.com/proxy?url='
];

// Round-robin selection
let currentProxy = 0;
function getNextProxy() {
  const proxy = proxyServers[currentProxy];
  currentProxy = (currentProxy + 1) % proxyServers.length;
  return proxy;
}
```

---

## 💰 Costs

- **$5/month VPS**: Your current server ✅
- **Cloudflare Tunnel**: FREE ✅
- **Let's Encrypt SSL**: FREE ✅
- **Total**: $5/month (what you're already paying!)

---

## 🎉 Benefits

✅ **HTTP Services Work**: Bridge HTTP to HTTPS  
✅ **No CORS Issues**: Your proxy adds CORS headers  
✅ **Secure**: Everything encrypted via Cloudflare  
✅ **Fast**: Direct server, no third-party delays  
✅ **Private**: You control the proxy  
✅ **Reliable**: Not dependent on public proxies  
✅ **Free SSL**: Via Cloudflare Tunnel  
✅ **No Port Forwarding**: Cloudflare Tunnel handles it  

---

## 🆘 Troubleshooting

### Tunnel not connecting
```bash
# Check tunnel status
cloudflared tunnel info rabbit-proxy

# Restart tunnel
sudo systemctl restart cloudflared
```

### Proxy not responding
```bash
# Check if proxy is running
sudo systemctl status rabbit-proxy

# Check if port is listening
sudo netstat -tlnp | grep 3000

# Restart proxy
sudo systemctl restart rabbit-proxy
```

### CORS errors
- Make sure your RABBIT domain is in the CORS origin list
- Check browser console for exact error

---

## 🔄 Updates

To update the proxy:

```bash
cd ~/rabbit-proxy
nano server.js
# Make changes
sudo systemctl restart rabbit-proxy
```

---

## 📚 Next Steps

1. Set up the proxy (15 min)
2. Update RABBIT to use your proxy URL
3. Test with HTTP IPTV service
4. Share your RABBIT link with users!

Your users now get:
- ✅ HTTPS security
- ✅ HTTP IPTV support
- ✅ No local setup needed
- ✅ Works everywhere

---

**You just turned your $5/month server into a crucial infrastructure piece for RABBIT!** 🎉🐰

This is actually the BEST solution - better than public CORS proxies because you control it and it's reliable!
