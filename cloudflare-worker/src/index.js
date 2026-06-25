/**
 * DocFlow Issue Reporter — Cloudflare Worker
 *
 * Receives feature requests and feedback from the DocFlow app
 * and creates GitHub Issues using a stored PAT.
 *
 * Secrets (set in dashboard):
 *   GITHUB_TOKEN — fine-grained PAT with issues:write on celpha2svx/DocFlow
 *
 * Env vars (set in dashboard or wrangler.toml):
 *   REPO_OWNER = celpha2svx
 *   REPO_NAME  = DocFlow
 */

const API = 'https://api.github.com';
const FALLBACK_OWNER = 'celpha2svx';
const FALLBACK_NAME = 'DocFlow';

export default {
  async fetch(request, env) {
    const GITHUB_TOKEN = env.GITHUB_TOKEN;
    const REPO_OWNER   = env.REPO_OWNER || FALLBACK_OWNER;
    const REPO_NAME    = env.REPO_NAME  || FALLBACK_NAME;

    // ---- GET / — health check / test ----
    if (request.method === 'GET') {
      return html(`<!DOCTYPE html>
<html><body style="font-family:sans-serif;padding:2em;">
<h1>DocFlow Issue Reporter</h1>
<p>Worker is running.</p>
<p>Token set: <strong>${GITHUB_TOKEN ? 'YES' : 'NO'}</strong></p>
<p>Repo: ${REPO_OWNER}/${REPO_NAME}</p>
<p>To test, send a POST to <code>/submit</code> with JSON body <code>{"title":"Test","body":"Hello"}</code></p>
</body></html>`);
    }

    // ---- POST /submit — create GitHub Issue ----
    if (request.method !== 'POST') {
      return json({ error: 'Method not allowed' }, 405);
    }

    const url = new URL(request.url);
    if (url.pathname !== '/submit') {
      return json({ error: 'Not found' }, 404);
    }

    if (!GITHUB_TOKEN) {
      return json({ error: 'GITHUB_TOKEN secret not set. Go to dashboard → Settings → Variables → add secret.' }, 500);
    }

    let body;
    try {
      body = await request.json();
    } catch (e) {
      return json({ error: 'Invalid JSON body' }, 400);
    }

    const { title, body: bodyText, label } = body;
    if (!title || !bodyText) {
      return json({ error: 'title and body fields are required' }, 400);
    }

    try {
      const res = await fetch(`${API}/repos/${REPO_OWNER}/${REPO_NAME}/issues`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${GITHUB_TOKEN}`,
          Accept: 'application/vnd.github+json',
          'Content-Type': 'application/json',
          'User-Agent': 'docflow-worker',
        },
        body: JSON.stringify({
          title,
          body: bodyText,
          labels: label ? [label] : [],
        }),
      });

      const resBody = await res.text();
      if (res.ok) {
        return json({ ok: true, issue_url: JSON.parse(resBody).html_url }, 201);
      }

      console.error('GitHub API error:', res.status, resBody);
      return json({ error: `GitHub API returned ${res.status}`, detail: resBody }, 502);
    } catch (e) {
      console.error('Worker error:', e.message);
      return json({ error: e.message }, 500);
    }
  },
};

function json(data, status) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function html(content) {
  return new Response(content, {
    status: 200,
    headers: { 'Content-Type': 'text/html' },
  });
}
