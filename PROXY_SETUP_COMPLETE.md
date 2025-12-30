# 🎉 You Installed the Proxy! Now What?

## ✅ Quick Integration Checklist

### Step 1: Verify Your Proxy Works

```bash
# Test health endpoint
curl https://YOUR-DOMAIN.com/health

# Should return: {"status":"ok","service":"RABBIT CORS Proxy",...}
```

If this works, your proxy is running! 🎉

---

### Step 2: Update RABBIT to Use Your Proxy

You need to change the proxy URL in `index.html`:

#### Method A: Edit Directly on GitHub

1. Go to your RABBIT repository on GitHub
2. Click `index.html`
3. Click the pencil icon (Edit)
4. Find line ~1030 (search for `corsproxy.io`)
5. Change this line:

**FIND:**
```javascript
const corsProxies = [
    'https://proxy.yourdomain.com/m3u?url=',  // YOUR PROXY - Change this!
    'https://corsproxy.io/?',
```

**REPLACE WITH:**
```javascript
const corsProxies = [
    'https://YOUR-ACTUAL-DOMAIN.com/m3u?url=',  // ← Put your real domain here!
    'https://corsproxy.io/?',
```

6. Find the second location around line ~1120:

**FIND:**
```javascript
const corsProxies = [
    'https://proxy.yourdomain.com/proxy?url=',  // YOUR PROXY - Change this!
    'https://corsproxy.io/?',
```

**REPLACE WITH:**
```javascript
const corsProxies = [
    'https://YOUR-ACTUAL-DOMAIN.com/proxy?url=',  // ← Put your real domain here!
    'https://corsproxy.io/?',
```

7. Commit changes
8. Wait 1-2 minutes for Cloudflare Pages to redeploy

#### Method B: Edit Locally

```bash
# Clone your repo
git clone https://github.com/yourusername/RABBIT.git
cd RABBIT

# Edit index.html
nano index.html  # or use any text editor

# Find and replace (two locations):
# FROM: 'https://proxy.yourdomain.com/
# TO:   'https://YOUR-ACTUAL-DOMAIN.com/

# Commit and push
git add index.html
git commit -m "Update proxy URL"
git push
```

---

### Step 3: Update CORS Settings (Security)

Your proxy should only accept requests from your RABBIT domain:

```bash
# SSH into your server
ssh user@your-server

# Edit the proxy
sudo nano /opt/rabbit-proxy/.env
```

Add your RABBIT domain:
```bash
ALLOWED_ORIGINS=https://rabbit-30m.pages.dev,https://your-custom-domain.com
```

Restart the proxy:
```bash
sudo systemctl restart rabbit-proxy
```

---

### Step 4: Test Everything!

1. **Open your RABBIT site**: https://rabbit-30m.pages.dev
2. **Try an HTTP IPTV service**
3. **Watch the magic happen!** ✨

---

## 🎯 What Each Endpoint Does

Your proxy has 3 endpoints:

### 1. `/health` - Status Check
```bash
curl https://YOUR-DOMAIN.com/health
```
Returns proxy status. Use for monitoring.

### 2. `/m3u?url=` - M3U Playlists
```javascript
// In RABBIT, it uses this for M3U playlists
const url = 'https://YOUR-DOMAIN.com/m3u?url=' + encodeURIComponent(m3uUrl);
```

### 3. `/proxy?url=` - Xtream Codes API
```javascript
// In RABBIT, it uses this for Xtream Codes
const url = 'https://YOUR-DOMAIN.com/proxy?url=' + encodeURIComponent(apiUrl);
```

---

## 📊 Monitor Your Proxy

### Check if it's running
```bash
sudo systemctl status rabbit-proxy
```

### View live logs
```bash
sudo journalctl -u rabbit-proxy -f
```

### Check Cloudflare Tunnel (if using)
```bash
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f
```

### View access logs
You'll see requests like:
```
2025-01-15T10:30:45.123Z - GET /proxy?url=http://...
2025-01-15T10:30:46.456Z - GET /m3u?url=http://...
```

---

## 🔧 Common Issues

### Issue: "Cannot connect to proxy"

**Check 1**: Is the proxy running?
```bash
sudo systemctl status rabbit-proxy
```

**Check 2**: Is the domain resolving?
```bash
curl https://YOUR-DOMAIN.com/health
```

**Check 3**: Are the CORS origins correct?
```bash
cat /opt/rabbit-proxy/.env
```

### Issue: "CORS error"

Your RABBIT domain isn't in the allowed origins:

```bash
sudo nano /opt/rabbit-proxy/.env
# Add: ALLOWED_ORIGINS=https://rabbit-30m.pages.dev
sudo systemctl restart rabbit-proxy
```

### Issue: "Proxy returns 403/500"

The target IPTV service might be blocking your proxy's IP:

**Solution**: Add user agent or use residential proxy

Edit `/opt/rabbit-proxy/server.js`:
```javascript
headers: {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}
```

---

## 🎨 Customize Your Proxy

### Change Port

```bash
sudo nano /opt/rabbit-proxy/.env
# Change: PORT=3000
# To: PORT=5000

sudo systemctl restart rabbit-proxy

# Update tunnel config if using Cloudflare Tunnel
sudo nano /etc/cloudflared/config.yml
# Change service: http://localhost:3000
# To: service: http://localhost:5000
sudo systemctl restart cloudflared
```

### Add Rate Limiting

Already included! 200 requests per 15 minutes per IP.

To change:
```bash
sudo nano /opt/rabbit-proxy/server.js
```

Find:
```javascript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200  // ← Change this number
});
```

### Add Authentication (Optional)

```bash
sudo nano /opt/rabbit-proxy/server.js
```

Add before routes:
```javascript
const AUTH_TOKEN = 'your-secret-token-here';

app.use((req, res, next) => {
  if (req.path === '/health') return next(); // Skip for health check
  
  const token = req.headers['x-api-key'];
  if (token !== AUTH_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});
```

Then in RABBIT, add header:
```javascript
fetch(proxyUrl, {
  headers: { 'X-API-Key': 'your-secret-token-here' }
})
```

---

## 📈 Scale Your Proxy

### Current Capacity
Your $5 server can handle:
- ~100-200 concurrent users
- Millions of requests per month
- Multiple RABBIT instances

### Need More?

**Option 1**: Upgrade server
- $10/month → 400-500 users
- $20/month → 1000+ users

**Option 2**: Multiple servers
```javascript
// In RABBIT index.html
const corsProxies = [
  'https://proxy1.yourdomain.com/proxy?url=',
  'https://proxy2.yourdomain.com/proxy?url=',
  'https://proxy3.yourdomain.com/proxy?url='
];
```

**Option 3**: Add CDN caching
```nginx
# In Nginx config
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m;

location / {
    proxy_cache my_cache;
    proxy_cache_valid 200 1h;
    ...
}
```

---

## 🎉 Success Checklist

- [ ] Proxy installed and running
- [ ] Health check returns OK
- [ ] RABBIT updated with proxy URL
- [ ] CORS origins configured
- [ ] Tested with HTTP IPTV service
- [ ] Monitoring setup (optional)

---

## 🆘 Still Stuck?

### Quick Debug Commands

```bash
# Check everything at once
echo "=== Proxy Status ===" && \
sudo systemctl status rabbit-proxy && \
echo "=== Cloudflare Tunnel Status ===" && \
sudo systemctl status cloudflared && \
echo "=== Last 10 Proxy Logs ===" && \
sudo journalctl -u rabbit-proxy -n 10 && \
echo "=== Test Health ===" && \
curl https://YOUR-DOMAIN.com/health
```

### Get Help

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Check [PROXY_SERVER.md](PROXY_SERVER.md)
3. Open issue: https://github.com/michaelrobgrove/RABBIT/issues
4. Include:
   - Error messages
   - Proxy logs
   - What you tried

---

## 💡 Pro Tips

1. **Bookmark your health check**
   - https://YOUR-DOMAIN.com/health
   - Check it regularly

2. **Set up monitoring** (Optional)
   - Use UptimeRobot (free)
   - Monitors your proxy 24/7
   - Alerts you if it goes down

3. **Keep logs rotating**
   ```bash
   sudo journalctl --vacuum-time=7d
   ```

4. **Update regularly**
   ```bash
   cd /opt/rabbit-proxy
   git pull  # if you git cloned
   npm update
   sudo systemctl restart rabbit-proxy
   ```

---

## 🎊 Congratulations!

You now have your own private CORS proxy that bridges HTTP IPTV services to your HTTPS RABBIT site!

**Your users get**:
- ✅ Secure HTTPS connection
- ✅ HTTP IPTV support
- ✅ No setup required
- ✅ Fast and reliable

**You get**:
- ✅ Full control
- ✅ Better privacy
- ✅ Better reliability
- ✅ Only $5/month

---

**Need the domain configured?** Don't forget to:
1. Point your domain to Cloudflare Tunnel (already done by setup script)
2. Or point your domain to your server IP (if using Nginx)
3. Update the domain in both RABBIT locations

**Questions?** Open an issue on GitHub!
