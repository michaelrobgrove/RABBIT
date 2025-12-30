# RABBIT Project Structure

```
RABBIT/
│
├── index.html              # Main application file (complete web app)
├── images/
│   └── rabbit.svg         # RABBIT logo
│
├── README.md              # Project documentation
├── DEPLOYMENT.md          # Deployment instructions
├── LICENSE                # MIT License
├── .gitignore            # Git ignore rules
│
└── (Future additions)
    ├── CHANGELOG.md      # Version history
    ├── CONTRIBUTING.md   # Contribution guidelines
    └── docs/             # Additional documentation
```

## File Descriptions

### `index.html`
The complete web application in a single file:
- **Landing Page**: Marketing page with features, privacy info, and support section
- **App Interface**: IPTV player with login forms, video player, and TV guide
- **Styling**: All CSS embedded (no external stylesheets needed)
- **JavaScript**: All functionality embedded (no external scripts needed)

**Size**: ~40KB (uncompressed)
**Dependencies**: None (100% vanilla HTML/CSS/JS)

### `images/rabbit.svg`
Vector logo of RABBIT:
- **Format**: SVG (Scalable Vector Graphics)
- **Size**: ~4KB
- **Color**: White (#fdfcfc)
- **Usage**: Header logo, favicon, branding

### `README.md`
Complete project documentation:
- Features overview
- Privacy policy
- Usage instructions
- Contribution guidelines
- Support information

### `DEPLOYMENT.md`
Deployment instructions for:
- Cloudflare Pages
- GitHub Pages
- Vercel
- Netlify
- Self-hosting
- Docker

### `LICENSE`
MIT License - Free and open source

---

## Technical Details

### Technologies Used
- **HTML5**: Semantic markup, video element
- **CSS3**: Modern features (Grid, Flexbox, CSS Variables)
- **JavaScript (ES6+)**: Modern syntax, no transpiling needed
- **Web APIs**: 
  - SessionStorage API
  - Fullscreen API
  - HTML5 Video API
  - Fetch API

### Browser Compatibility
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers supported

### Performance
- **Load Time**: < 1 second
- **Bundle Size**: ~40KB (uncompressed), ~12KB (gzipped)
- **No External Dependencies**: Everything in one file
- **No Build Step**: Deploy as-is

---

## Adding New Features

RABBIT is designed to be easily extended. Here are some common modifications:

### 1. Adding Custom Themes
Edit CSS variables in `index.html`:
```css
:root {
    --primary-black: #0a0a0a;
    --cobalt-blue: #0047FF;
    /* Add your colors */
}
```

### 2. Adding Analytics
Insert before closing `</body>`:
```html
<script src="your-analytics.js"></script>
```

### 3. Adding More Login Methods
Add new form in the login section:
```javascript
function loginCustom(event) {
    // Your login logic
}
```

### 4. Customizing the Logo
Replace `images/rabbit.svg` with your logo

### 5. Adding Translations
Create translation object:
```javascript
const translations = {
    en: { /* English strings */ },
    es: { /* Spanish strings */ }
};
```

---

## Development Workflow

### 1. Clone & Setup
```bash
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT
```

### 2. Local Development
```bash
# Option 1: Python
python -m http.server 8000

# Option 2: Node.js
npx http-server

# Option 3: PHP
php -S localhost:8000
```

### 3. Make Changes
Edit `index.html` directly

### 4. Test
- Test in multiple browsers
- Test on mobile devices
- Test with real IPTV services

### 5. Deploy
Push to GitHub and deploy via your chosen platform

---

## Future Roadmap

Potential features (contributions welcome!):

### v1.1
- [ ] Favorites system
- [ ] Search functionality
- [ ] Picture-in-picture mode
- [ ] Keyboard shortcuts

### v1.2
- [ ] Multi-language support
- [ ] Theme switcher (dark/light)
- [ ] Enhanced EPG support
- [ ] Channel groups/categories

### v1.3
- [ ] Chromecast integration
- [ ] AirPlay support
- [ ] Parental controls
- [ ] Watch history (local)

### v2.0
- [ ] Progressive Web App (PWA)
- [ ] Offline support
- [ ] Service worker caching
- [ ] Mobile app versions

---

## Contributing

See potential improvements? Here's how to contribute:

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

All contributions must maintain:
- Privacy-first approach
- No external dependencies (unless absolutely necessary)
- Clean, readable code
- Mobile responsiveness
- Browser compatibility

---

## Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/michaelrobgrove/RABBIT/issues)
- **Discussions**: [Ask questions or share ideas](https://github.com/michaelrobgrove/RABBIT/discussions)
- **Email**: Via [YourDSGNPro](https://yourdsgn.pro)

---

## Credits

**Created by**: Michael R. Grove
**Website**: [YourDSGNPro](https://yourdsgn.pro)
**License**: MIT
**Font**: [Barlow Condensed](https://fonts.google.com/specimen/Barlow+Condensed)

---

**Remember**: Keep it simple. Keep it private. Keep it open.