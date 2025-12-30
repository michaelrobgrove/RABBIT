// Cloudflare Worker - RABBIT Enhanced Proxy
// Handles M3U8 playlists and video segments with proper CORS and caching

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
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-User-Agent, Range',
        'Access-Control-Max-Age': '86400',
      },
    })
  }

  if (!targetUrl) {
    return new Response('Missing "url" parameter. Usage: /?url=https://example.com', { status: 400 })
  }

  // 2. Prepare the Request
  const userAgent = request.headers.get('X-User-Agent') || 'IPTVSmartersPro';
  
  const newHeaders = new Headers()
  newHeaders.set('User-Agent', userAgent)
  
  // Forward Range header for video segments (critical for seeking)
  const rangeHeader = request.headers.get('Range')
  if (rangeHeader) {
    newHeaders.set('Range', rangeHeader)
  }
  
  // Set origin headers to bypass IPTV server restrictions
  try {
    const targetOrigin = new URL(targetUrl).origin
    newHeaders.set('Origin', targetOrigin)
    newHeaders.set('Referer', targetOrigin + '/')
  } catch(e) {}

  // 3. Fetch from Target with retry logic
  let response
  try {
    response = await fetch(targetUrl, {
      method: request.method,
      headers: newHeaders,
      redirect: 'follow',
      cf: {
        // Cloudflare-specific caching for video segments
        cacheTtl: targetUrl.endsWith('.ts') ? 3600 : 300,
        cacheEverything: true
      }
    })
  } catch (err) {
    return new Response(`Proxy Fetch Error: ${err.message}`, { 
      status: 502,
      headers: { 'Access-Control-Allow-Origin': '*' }
    })
  }

  // 4. Prepare Response with proper CORS headers
  const responseHeaders = new Headers(response.headers)
  responseHeaders.set('Access-Control-Allow-Origin', '*')
  responseHeaders.set('Access-Control-Expose-Headers', '*')
  responseHeaders.set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
  
  // Ensure correct content types for HLS
  if (!responseHeaders.has('content-type')) {
    if(targetUrl.endsWith('.m3u8') || targetUrl.includes('.m3u8')) {
      responseHeaders.set('content-type', 'application/vnd.apple.mpegurl')
    } else if(targetUrl.endsWith('.ts')) {
      responseHeaders.set('content-type', 'video/mp2t')
    }
  }
  
  // Add cache headers for better performance
  if (targetUrl.endsWith('.ts')) {
    responseHeaders.set('Cache-Control', 'public, max-age=3600')
  } else if (targetUrl.endsWith('.m3u8')) {
    responseHeaders.set('Cache-Control', 'public, max-age=10')
  }

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: responseHeaders
  })
}