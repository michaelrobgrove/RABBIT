# RABBIT Troubleshooting Guide

## 🔧 Common Issues & Solutions

---

## Issue 1: CORS Error (Access-Control-Allow-Origin)

### What it means:
The IPTV service doesn't allow your browser to access their content from a different domain.

### Error looks like:
```
Access to fetch at 'https://example.com/playlist.m3u' has been blocked by CORS policy
```

### Solutions:

#### Option 1: Use CORS Proxy (Built-in)
RABBIT now automatically tries to use a CORS proxy if direct connection fails. Just try connecting normally.

#### Option 2: Download M3U and Self-Host
```bash
# Download your M3U file
curl -o playlist.m3u "YOUR_M3U_URL"

# Host it locally with RABBIT
python -m http.server 8000

# Use: http://localhost:8000/playlist.m3u
```

#### Option 3: Browser Extension (Development Only)
Install a CORS unblock extension:
- [CORS Unblock](https://chrome.google.com/webstore) for Chrome
- [CORS Everywhere](https://addons.mozilla.org/en-US/firefox/) for Firefox

**⚠️ Warning**: Only use for testing. Don't leave enabled permanently.

#### Option 4: Self-Host RABBIT
Deploy RABBIT on the same domain as your IPTV service to avoid CORS entirely.

---

## Issue 2: Mixed Content (HTTP on HTTPS site)

### What it means:
Your IPTV server uses HTTP but RABBIT is served over HTTPS. Browsers block this for security.

### Error looks like:
```
Mixed Content: The page at 'https://rabbit-30m.pages.dev/' was loaded over HTTPS, 
but requested an insecure resource 'http://example.com/...'. This request has been blocked.
```

### Solutions:

#### Option 1: Ask Provider for HTTPS
Contact your IPTV provider and ask for HTTPS URLs. Many modern services support this.

#### Option 2: Self-Host RABBIT Locally (Recommended)
```bash
# Clone RABBIT
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Run on HTTP locally
python -m http.server 8000

# Access at: http://localhost:8000
```

This runs RABBIT on HTTP, so HTTP IPTV servers will work.

#### Option 3: Use Desktop IPTV Player
For HTTP-only services, consider using:
- VLC Media Player
- IPTV Smarters
- TiviMate

#### Option 4: VPN/Proxy Setup
Set up a local HTTPS proxy that forwards to HTTP IPTV servers:

```bash
# Using nginx as HTTPS proxy
server {
    listen 443 ssl;
    server_name local.rabbit.tv;
    
    location / {
        proxy_pass http://your-iptv-server.com;
    }
}
```

---

## Issue 3: Google Drive Direct Links Not Working

### Problem:
Google Drive share links don't work as direct M3U URLs.

### Solution:
Convert Google Drive links to direct download links:

**Original Link:**
```
https://drive.google.com/file/d/FILE_ID/view?usp=sharing
```

**Convert to:**
```
https://drive.google.com/uc?export=download&id=FILE_ID
```

**Better Solution:** Host M3U files on:
- GitHub (raw.githubusercontent.com)
- Your own web server
- Pastebin (raw links)
- Dropbox (with direct link enabled)

---

## Issue 4: Channels Not Loading

### Checklist:

1. **Verify M3U Format**
   ```m3u
   #EXTM3U
   #EXTINF:-1,Channel Name
   http://example.com/stream.m3u8
   ```

2. **Test in VLC First**
   - Open VLC → Media → Open Network Stream
   - Paste your M3U URL
   - If it doesn't work in VLC, it won't work in RABBIT

3. **Check Stream URLs**
   - Make sure stream URLs are valid
   - Test individual stream URLs

4. **Verify Credentials**
   - Double-check username/password
   - Ensure subscription is active
   - Try logging in on provider's website

---

## Issue 5: Video Won't Play

### Possible Causes & Fixes:

#### Cause 1: Unsupported Format
**Solution**: RABBIT uses HTML5 video which supports:
- MP4
- WebM
- HLS (.m3u8)

Most IPTV streams use HLS, which should work fine.

#### Cause 2: DRM-Protected Content
**Solution**: RABBIT doesn't support DRM. Use provider's official app for DRM content.

#### Cause 3: Geographic Restrictions
**Solution**: 
- Use VPN to access geo-blocked content
- Contact provider about access

#### Cause 4: Browser Compatibility
**Solution**: Try a different browser:
- Chrome (recommended)
- Firefox
- Safari
- Edge

---

## Issue 6: Site Won't Load

### Solutions:

1. **Clear Browser Cache**
   ```
   Chrome: Ctrl+Shift+Delete → Clear cache
   Firefox: Ctrl+Shift+Delete → Clear cache
   Safari: Cmd+Option+E
   ```

2. **Disable Browser Extensions**
   - Ad blockers might interfere
   - Try in incognito/private mode

3. **Check Internet Connection**
   - Run speed test
   - Restart router

4. **Try Different Browser**
   - Update to latest version
   - Try another browser

---

## Issue 7: Performance/Buffering

### Optimization Tips:

1. **Check Internet Speed**
   - Need 5+ Mbps for SD
   - Need 25+ Mbps for HD
   - Need 50+ Mbps for 4K

2. **Close Other Tabs**
   - Free up memory
   - Reduce bandwidth usage

3. **Lower Video Quality**
   - If provider offers quality options
   - Ask about SD vs HD streams

4. **Use Wired Connection**
   - Ethernet is more stable than WiFi
   - Reduces buffering

---

## Issue 8: Fullscreen Not Working

### Solutions:

1. **Browser Permissions**
   - Allow fullscreen in browser settings
   - Check site permissions

2. **Keyboard Shortcuts**
   - Try F11 (browser fullscreen)
   - Try double-click on video

3. **Browser Compatibility**
   - Update browser to latest version
   - Try different browser

---

## Issue 9: Mobile Issues

### Common Mobile Problems:

1. **Video Won't Play**
   - Mobile browsers have different codecs
   - Try Chrome mobile or Firefox mobile
   - Some streams don't support mobile

2. **Controls Not Visible**
   - Tap video to show controls
   - Use landscape mode
   - Zoom out if needed

3. **App Keeps Closing**
   - Clear browser cache
   - Restart phone
   - Free up memory

---

## Still Having Issues?

### Debug Steps:

1. **Open Browser Console**
   ```
   Chrome: F12 → Console tab
   Firefox: F12 → Console tab
   Safari: Cmd+Option+C
   ```

2. **Look for Error Messages**
   - Note any red errors
   - Copy full error text

3. **Report Issue**
   - Go to: https://github.com/michaelrobgrove/RABBIT/issues
   - Click "New Issue"
   - Provide:
     - Browser and version
     - Error message
     - Steps to reproduce
     - What you expected to happen

### Alternative: Self-Host Solution

If cloud-hosted RABBIT doesn't work for your setup, try self-hosting:

```bash
# Clone repo
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Run locally on HTTP (solves most CORS/HTTPS issues)
python -m http.server 8000

# Access at: http://localhost:8000
```

This gives you full control and avoids CORS/HTTPS restrictions.

---

## Provider-Specific Notes

### Xtream Codes Providers

- Must use correct port (usually 8080 or 80)
- Format: `http://server.com:8080`
- Some providers block web players

### M3U Providers

- Make sure URL ends in `.m3u` or `.m3u8`
- Use raw/direct links, not share pages
- Some providers require tokens that expire

### Free IPTV Lists

- Often blocked by CORS
- Streams frequently go down
- Better to download and host yourself

---

## Security Reminders

- Never share your credentials
- Use strong passwords
- Don't use public WiFi for IPTV
- Keep provider info private
- RABBIT never stores or transmits your data

---

## Getting Help

1. **Documentation**: Read README.md and DEPLOYMENT.md
2. **GitHub Issues**: https://github.com/michaelrobgrove/RABBIT/issues
3. **GitHub Discussions**: https://github.com/michaelrobgrove/RABBIT/discussions
4. **Contact**: Via [YourDSGNPro](https://yourdsgn.pro)

---

**Remember**: Most issues are related to CORS or HTTPS restrictions, not RABBIT itself. Self-hosting locally often solves these problems immediately.

---

**Last Updated**: December 2025
**Version**: 1.0.0