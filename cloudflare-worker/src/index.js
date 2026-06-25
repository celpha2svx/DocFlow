/**
 * DocFlow Issue Reporter — Cloudflare Worker
 *
 * Receives feature requests and feedback from the DocFlow app
 * and creates GitHub Issues using a stored PAT.
 *
 * Deploy:
 *   1. wrangler secret put GITHUB_TOKEN   (fine-grained PAT, issues:write)
 *   2. wrangler deploy
 */

const API = 'https://api.github.com';

export default {
  async fetch(request, env) {
    const { GITHUB_TOKEN, REPO_OWNER, REPO_NAME } = env;

    if (request.method !== 'POST') {
      return json({ error: 'Method not allowed' }, 405);
    }

    const url = new URL(request.url);
    if (url.pathname !== '/submit') {
      return json({ error: 'Not found' }, 404);
    }

    if (!GITHUB_TOKEN) {
      return json({ error: 'Server misconfigured' }, 500);
    }

    try {
      const { title, body, label } = await request.json();

      if (!title || !body) {
        return json({ error: 'title and body are required' }, 400);
      }

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
          body,
          labels: label ? [label] : [],
        }),
      });

      if (res.ok) {
        return json({ ok: true }, 201);
      }

      const err = await res.text();
      console.error('GitHub API error:', res.status, err);
      return json({ error: 'GitHub API error' }, 502);
    } catch (e) {
      console.error('Worker error:', e.message);
      return json({ error: 'Internal error' }, 500);
    }
  },
};

function json(data, status) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
