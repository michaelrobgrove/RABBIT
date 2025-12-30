<div align="center">
  <img src="images/rabbit.svg" alt="RABBIT Logo" width="150" height="150">
  
  # RABBIT
  
  ### **The Free, Open-Source IPTV Player You Can Trust**
  
  ![License](https://img.shields.io/badge/license-MIT-blue.svg)
  ![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)
  ![Privacy](https://img.shields.io/badge/privacy-first-success.svg)
  
  [Launch Player](https://michaelrobgrove.github.io/RABBIT) • [Report Bug](https://github.com/michaelrobgrove/RABBIT/issues) • [Request Feature](https://github.com/michaelrobgrove/RABBIT/issues)
</div>

---

## 🚀 What is RABBIT?

**RABBIT** is a modern, privacy-focused IPTV player built with simplicity and user trust at its core. No accounts. No tracking. No data collection. Just a clean, powerful web-based player that respects your privacy.

### ✨ Key Features

- **🔒 100% Private** - All credentials stored locally on your device. Zero data collection. Zero tracking.
- **🌐 Multiple Login Methods** - Support for M3U playlists with EPG and Xtream Codes API
- **📺 Clean TV Guide** - 4-hour program guide with intuitive channel switching
- **🎬 Full Media Controls** - Fullscreen, volume, mute, and cast support
- **⚡ Lightning Fast** - No bloat. No ads. Pure performance.
- **💻 Open Source** - Completely transparent code you can audit and improve

---

## 🎯 Why RABBIT?

In an age where every service wants your data, RABBIT stands apart:

- **Your data stays yours** - We don't store your credentials. They live in your browser's session storage and disappear when you close the tab.
- **No tracking pixels** - We don't know who you are, what you watch, or when you watch it.
- **No accounts required** - Jump right in. No sign-ups, no emails, no hassle.
- **Open and transparent** - Every line of code is here for you to review.

---

## 🛠️ Installation

> **⚠️ IMPORTANT: HTTP IPTV Services**  
> If your IPTV service uses HTTP (not HTTPS), you'll need to run RABBIT locally.  
> **Quick Start**: See [LOCAL_HOSTING.md](LOCAL_HOSTING.md) for easy 30-second setup!

### Option 1: Use the Hosted Version (HTTPS Services Only)
Simply visit: **[Launch RABBIT](https://rabbit-30m.pages.dev)**

*Note: Only works with HTTPS IPTV services due to browser security*

### Option 2: Run Locally (Recommended - Works with ALL Services)

**Supports both HTTP and HTTPS IPTV services!**

```bash
# Download
git clone https://github.com/michaelrobgrove/RABBIT.git
cd RABBIT

# Run local server
python -m http.server 8000

# Open: http://localhost:8000
```

**Full guide**: [LOCAL_HOSTING.md](LOCAL_HOSTING.md)

### Option 3: Deploy to Cloudflare Pages (HTTPS Services Only)

1. Fork this repository
2. Connect your fork to Cloudflare Pages
3. Deploy with default settings
4. Done! ✅

---

## 📖 How to Use

### M3U Playlist Method

1. Click "Launch Player"
2. Select "M3U Playlist" tab
3. Enter your M3U playlist URL
4. (Optional) Add EPG URL for program guide
5. Click "Connect"
6. Start watching!

### Xtream Codes Method

1. Click "Launch Player"
2. Select "Xtream Codes" tab
3. Enter your server URL
4. Enter your username
5. Enter your password
6. Click "Connect"
7. Start watching!

---

## 🔐 Privacy & Security

### What We Store
- **Session Storage Only** - Credentials are stored in your browser's sessionStorage
- **Temporary** - All data is cleared when you close the browser tab
- **Local** - Nothing is ever transmitted to our servers

### What We DON'T Collect
- ❌ No usage logs
- ❌ No analytics
- ❌ No tracking cookies
- ❌ No user accounts
- ❌ No personal information
- ❌ No viewing history

**Your privacy is absolute.**

---

## 🎨 Technology Stack

- **Pure HTML/CSS/JavaScript** - No frameworks, no build process
- **Modern Web APIs** - HTML5 Video, Fullscreen API, SessionStorage
- **Responsive Design** - Works on desktop, tablet, and mobile
- **CORS-Friendly** - Compatible with most IPTV services

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution
- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🌍 Translations
- 🎨 UI/UX enhancements

---

## 🐛 Known Issues & Limitations

- **CORS Restrictions** - Some IPTV services block cross-origin requests. RABBIT includes automatic CORS proxy fallback, but if issues persist, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Mixed Content** - HTTPS sites (like Cloudflare Pages) block HTTP content. For HTTP-only IPTV servers, self-host RABBIT locally. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Browser Support** - Modern browsers only (Chrome, Firefox, Safari, Edge)
- **EPG Support** - EPG parsing is basic and may not work with all formats
- **Cast Feature** - Cast functionality requires additional Chromecast integration

**Having connection issues?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

---

## 📋 Roadmap

- [ ] Enhanced EPG support
- [ ] Favorites/bookmarks
- [ ] Multi-language support
- [ ] Chromecast integration
- [ ] Picture-in-picture mode
- [ ] Keyboard shortcuts
- [ ] Dark/light theme toggle
- [ ] Mobile app versions

---

## ☕ Support the Project

RABBIT is completely free and always will be. If you find it useful and want to support continued development:

<div align="center">
  
  [![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/yourdsgnpro)
  
</div>

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Michael R. Grove**

- Website: [YourDSGNPro](https://yourdsgn.pro)
- GitHub: [@michaelrobgrove](https://github.com/michaelrobgrove)
- Buy Me a Coffee: [yourdsgnpro](https://buymeacoffee.com/yourdsgnpro)

---

## ⚠️ Disclaimer

RABBIT is a player interface only. It does not provide, host, or distribute any IPTV content. Users are responsible for ensuring they have legal access to any streams they view through this player.

---

## 🙏 Acknowledgments

- Thanks to all contributors who help improve RABBIT
- Built with inspiration from the open-source community
- Font: [Barlow Condensed](https://fonts.google.com/specimen/Barlow+Condensed) by Jeremy Tribby

---

<div align="center">
  
  **Open Source • Privacy First • Community Driven**
  
  Copyright © 2025 Michael R. Grove, [YourDSGNPro](https://yourdsgn.pro)
  
  Made with ❤️ for the IPTV community
  
</div>
