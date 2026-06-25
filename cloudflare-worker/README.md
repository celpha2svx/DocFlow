# DocFlow Issue Reporter Worker

Cloudflare Worker that receives feature requests and feedback from the DocFlow app and creates GitHub Issues.

## Setup

### Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Cloudflare account](https://dash.cloudflare.com/sign-up) (free tier)
- GitHub PAT with `issues: write` on `celpha2svx/DocFlow`

### Deploy

```bash
# Install wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Add your GitHub PAT as a secret
wrangler secret put GITHUB_TOKEN

# Deploy
wrangler deploy
```

After deploy, you'll get a URL like `https://docflow-issues.<subdomain>.workers.dev`.

### Configure the app

Copy the worker URL and paste it into `lib/services/issue_reporter.dart`:

```dart
static const String _workerUrl = 'https://docflow-issues.your-subdomain.workers.dev/submit';
```

## Usage

- `POST /submit` with JSON body:
  ```json
  {
    "title": "Calculator Request: MELD Score",
    "body": "**Calculator:** MELD Score\n\n**Use case:** Liver transplant triage\n\n**Specialty:** Gastroenterology\n\n**Priority:** urgent",
    "label": "calculator-request"
  }
  ```
