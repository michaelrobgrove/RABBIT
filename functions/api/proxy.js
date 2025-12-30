export async function onRequest({ request }) {
  const url = new URL(request.url);
  const target = url.searchParams.get("url");

  if (!target) {
    return new Response("Missing url", { status: 400 });
  }

  const upstream = await fetch(target, {
    headers: {
      "User-Agent": "IPTVSmartersPro",
      "Accept": "*/*",
      "Range": request.headers.get("Range") || ""
    }
  });

  const headers = new Headers(upstream.headers);

  headers.set("Access-Control-Allow-Origin", "*");
  headers.set("Access-Control-Allow-Headers", "*");
  headers.set("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS");

  return new Response(upstream.body, {
    status: upstream.status,
    headers
  });
}
