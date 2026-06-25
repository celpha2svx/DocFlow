const API = 'https://api.github.com';
const FALLBACK_OWNER = 'celpha2svx';
const FALLBACK_NAME = 'DocFlow';

export default {
  async fetch(request, env) {
    const GITHUB_TOKEN = env.GITHUB_TOKEN;
    const REPO_OWNER   = env.REPO_OWNER || FALLBACK_OWNER;
    const REPO_NAME    = env.REPO_NAME  || FALLBACK_NAME;

    // GET / — health check
    if (request.method === 'GET') {
      return html(`<h1>DocFlow Issue Reporter</h1>
<p>Token set: <strong>${GITHUB_TOKEN ? 'YES' : 'NO'}</strong></p>
<p>Repo: ${REPO_OWNER}/${REPO_NAME}</p>`);
    }

    // POST /submit — create GitHub Issue
    if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
    if (new URL(request.url).pathname !== '/submit') return json({ error: 'Not found' }, 404);
    if (!GITHUB_TOKEN) return json({ error: 'GITHUB_TOKEN secret not set' }, 500);

    let body;
    try { body = await request.json(); } catch (e) { return json({ error: 'Invalid JSON' }, 400); }
    const { title, body: bodyText, label } = body;
    if (!title || !bodyText) return json({ error: 'title and body required' }, 400);

    const res = await fetch(`${API}/repos/${REPO_OWNER}/${REPO_NAME}/issues`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${GITHUB_TOKEN}`, 'Content-Type': 'application/json', 'Accept': 'application/vnd.github+json' },
      body: JSON.stringify({ title, body: bodyText, labels: label ? [label] : [] }),
    });
    const resBody = await res.text();
    if (res.ok) return json({ ok: true, issue_url: JSON.parse(resBody).html_url }, 201);
    return json({ error: `GitHub API ${res.status}`, detail: resBody }, 502);
  },
};
function json(d, s) { return new Response(JSON.stringify(d,null,2), {status:s, headers:{'Content-Type':'application/json'}}); }
function html(c) { return new Response(c, {status:200, headers:{'Content-Type':'text/html'}}); }
