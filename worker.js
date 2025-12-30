// Cloudflare Worker - RABBIT Proxy
// Deploys to your Cloudflare account for free.

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const targetUrl = url.searchParams.get('url')

  // 1. Handle CORS Preflight (OPTIONS)
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, HEAD, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-User-Agent',
        'Access-Control-Max-Age': '86400',
      },
    })
  }

  if (!targetUrl) {
    return new Response('Missing "url" parameter. Usage: /?url=https://example.com', { status: 400 })
  }

  // 2. Prepare the Request
  // Default to Smarters Pro if no custom header is sent
  const userAgent = request.headers.get('X-User-Agent') || 'IPTVSmartersPro';
  
  const newHeaders = new Headers(request.headers)
  newHeaders.set('User-Agent', userAgent)
  newHeaders.set('Origin', new URL(targetUrl).origin) // Lie about origin to target
  newHeaders.set('Referer', new URL(targetUrl).origin)

  // 3. Fetch from Target
  try {
    const response = await fetch(targetUrl, {
      method: request.method,
      headers: newHeaders,
      redirect: 'follow'
    })

    // 4. Prepare Response
    const responseHeaders = new Headers(response.headers)
    responseHeaders.set('Access-Control-Allow-Origin', '*')
    responseHeaders.set('Access-Control-Expose-Headers', '*')
    
    // Fix for HLS: Ensure content-type is passed through
    if (!responseHeaders.has('content-type')) {
        if(targetUrl.endsWith('.m3u8')) responseHeaders.set('content-type', 'application/vnd.apple.mpegurl');
        if(targetUrl.endsWith('.ts')) responseHeaders.set('content-type', 'video/mp2t');
    }

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: responseHeaders
    })

  } catch (err) {
    return new Response(`Proxy Error: ${err.message}`, { status: 500 })
  }
}
