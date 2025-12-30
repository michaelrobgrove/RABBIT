# RABBIT Deployment Guide

## 🚀 Quick Start

RABBIT is a static web application that can be deployed anywhere. Here are several deployment options:

---

## Option 1: Cloudflare Pages (Recommended)

### Why Cloudflare Pages?
- Free hosting
- Global CDN
- HTTPS by default
- Zero configuration
- Perfect for static sites

### Steps:

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/RABBIT.git
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages**
   - Log in to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Go to Pages
   - Click "Create a project"
   - Connect your GitHub account
   - Select your RABBIT repository

3. **Configure Build Settings**
   - **Framework preset**: None
   - **Build command**: (leave empty)
   - **Build output directory**: `/`
   - Click "Save and Deploy"

4. **Done!** 🎉
   Your site will be live at `your-project.pages.dev`

### Custom Domain (Optional)
- Add a custom domain in the Pages settings
- Update your DNS records as instructed
- SSL is automatic

---

## Option 2: GitHub Pages

### Steps:

1. **Enable GitHub Pages**
   - Go to your repository settings
   - Navigate to "Pages" section
   - Select "Deploy from a branch"
   - Choose `main` branch and `/` (root) directory
   - Click "Save"

2. **Access Your Site**
   - Your site will be available at: `https://yourusername.github.io/RABBIT/`

### Custom Domain (Optional)
- Add a `CNAME` file with your domain
- Configure DNS settings with your domain provider

---

## Option 3: Vercel

### Steps:

1. **Install Vercel CLI** (optional)
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Connect your GitHub repository
   - Click "Deploy"

   OR use CLI:
   ```bash
   vercel --prod
   ```

3. **Done!**
   Your site is live at the provided URL

---

## Option 4: Netlify

### Steps:

1. **Deploy to Netlify**
   - Go to [netlify.com](https://netlify.com)
   - Click "Add new site" → "Import an existing project"
   - Connect to Git provider
   - Select your RABBIT repository
   - Build settings:
     - **Build command**: (leave empty)
     - **Publish directory**: `/`
   - Click "Deploy"

2. **Done!**
   Your site is live with auto-SSL

---

## Option 5: Self-Hosting

### Requirements:
- Any web server (Apache, Nginx, etc.)
- OR simple HTTP server

### Using Python:
```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

### Using Node.js:
```bash
npx http-server -p 8000
```

### Using PHP:
```bash
php -S localhost:8000
```

### Nginx Configuration:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /path/to/RABBIT;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Apache Configuration:
```apache
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /path/to/RABBIT
    
    <Directory /path/to/RABBIT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

---

## Option 6: Docker

### Create `Dockerfile`:
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Build and Run:
```bash
# Build image
docker build -t rabbit-iptv .

# Run container
docker run -d -p 8080:80 rabbit-iptv
```

### Access:
Open `http://localhost:8080`

---

## 🔧 Configuration

No configuration needed! RABBIT works out of the box.

### Optional: Custom Logo
Replace `images/rabbit.svg` with your own logo (keep the filename)

### Optional: Customize Colors
Edit the CSS variables in `index.html`:
```css
:root {
    --primary-black: #0a0a0a;
    --secondary-black: #1a1a1a;
    --cobalt-blue: #0047FF;
    --cobalt-glow: #1e5eff;
    --white: #ffffff;
    --gray: #a0a0a0;
}
```

---

## 🌍 Environment Notes

### CORS Issues
Some IPTV services may have CORS restrictions. Options:

1. **Use CORS Proxy**
   ```javascript
   const proxyUrl = 'https://cors-anywhere.herokuapp.com/';
   fetch(proxyUrl + m3uUrl)
   ```

2. **Browser Extension**
   Install a CORS unblock extension (development only)

3. **Self-Host**
   Deploy on the same domain as your IPTV service

### Browser Support
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Mobile Support
Fully responsive and works on:
- iOS Safari
- Android Chrome
- Mobile Firefox

---

## 📊 Monitoring

Since RABBIT doesn't collect any data, there's no built-in analytics. If you want to track usage:

### Option 1: Cloudflare Analytics
- Enabled automatically on Cloudflare Pages
- Privacy-friendly, no cookies

### Option 2: Self-hosted Analytics
- [Plausible](https://plausible.io) (privacy-friendly)
- [Umami](https://umami.is) (open-source)

---

## 🔒 Security Considerations

1. **HTTPS Only**
   - Always deploy with HTTPS (automatic on modern platforms)
   - Mixed content (HTTP/HTTPS) may cause issues

2. **No Backend**
   - All processing happens client-side
   - No server logs to secure

3. **Session Storage**
   - Credentials cleared when tab closes
   - More secure than localStorage

4. **Content Security Policy** (Optional)
   Add to HTML `<head>`:
   ```html
   <meta http-equiv="Content-Security-Policy" 
         content="default-src 'self'; 
                  script-src 'self' 'unsafe-inline'; 
                  style-src 'self' 'unsafe-inline';">
   ```

---

## 🆘 Troubleshooting

### Video won't play
- Check CORS settings
- Verify M3U/Xtream URL is correct
- Try a different browser
- Check browser console for errors

### Channels not loading
- Verify credentials are correct
- Check M3U format is valid
- Test M3U URL in VLC first
- Check network tab in browser dev tools

### Performance issues
- Clear browser cache
- Close other tabs
- Check internet connection
- Try different video quality

---

## 📝 Post-Deployment Checklist

- [ ] Site loads correctly
- [ ] Logo displays properly
- [ ] Both login methods work
- [ ] Video playback works
- [ ] Channel switching works
- [ ] Fullscreen works
- [ ] Volume controls work
- [ ] Mobile responsive
- [ ] HTTPS enabled
- [ ] Custom domain configured (if applicable)

---

## 🎉 You're Live!

Your RABBIT IPTV player is now deployed and ready to use!

Need help? Open an issue on [GitHub](https://github.com/michaelrobgrove/RABBIT/issues).

---

**Made with ❤️ by Michael R. Grove**