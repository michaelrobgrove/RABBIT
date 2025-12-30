# 🚀 Deploy Your Own Free Proxy (Cloudflare Workers)

Public proxies are slow and block video. The best solution is to run your own proxy on **Cloudflare Workers**. It's **100% FREE** (up to 100k requests/day) and very fast.

## Step 1: Login to Cloudflare
1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Login or Sign up (free).

## Step 2: Create a Worker
1. In the sidebar, go to **Workers & Pages**.
2. Click **Create Application**.
3. Click **Create Worker**.
4. Name it `rabbit-proxy` (or whatever you like).
5. Click **Deploy**.

## Step 3: Add the Code
1. Click **Edit Code** button.
2. Delete the existing "Hello World" code on the left.
3. Copy and Paste the code from `worker.js` (included in this repo) into the editor.
4. Click **Save and Deploy** (top right).

## Step 4: Get Your URL
1. Go back to the dashboard (or look at the preview).
2. Copy your Worker URL.
   - It will look like: `https://rabbit-proxy.yourname.workers.dev`

## Step 5: Update RABBIT
1. Open `index.html` in your RABBIT project.
2. Find the `PROXIES` list (around line 500).
3. Add your new URL as the **Primary Proxy**:

```javascript
const PROXIES = [
    { url: 'https://rabbit-proxy.yourname.workers.dev/?url=', name: 'My Cloudflare Proxy' },
    // ... keep others as backup
];
```

**That's it!** You now have a private, high-speed video proxy that masquerades as Smarters Pro.
