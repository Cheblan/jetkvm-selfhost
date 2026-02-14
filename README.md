# JetKVM Cloud Self-Hosted

A hassle-free way to deploy your own JetKVM Cloud infrastructure. This repository provides a unified setup including the **Cloud UI**, **API**, and a **PostgreSQL** database, all pre-configured to work together.

## What's Inside?
* **Custom Cloud UI Dockerfile**: JetKVM donesn't provide one at the time.
* **Unified Docker Compose**: Deploys UI, API, and DB in one command.
* **Deployment Shell Script**: Automates cloning of freshest versions and building with your variables.
* **Step-by-step Guide**: To get all this working without a headache.

---

## Prerequisites

Before running the script, you need to prepare your environment variables and Google Cloud credentials.

### 1. Google OIDC Configuration
To allow users to log in, you need a free Google Cloud project:
1. Go to [Google Cloud Console](https://console.cloud.google.com/auth).
2. Create a **"Testing App"** under the OAuth consent screen.
3. Go to **Credentials** -> **Create Credentials** -> **OAuth Client ID**.
4. Select **Web Application**.
5. **Authorized redirect URIs**: Add `https://your-api-domain.com/auth/google/callback`.
6. Copy your `Client ID` and `Client Secret`.

### 2. Environment Setup
Edit two files in the root directory: `env-ui` and `env-api`.

**`env-ui` configuration:**
```env
# Your Cloud API URL
VITE_CLOUD_API=https://your-api-domain.com
```

**`env-api` configuration:**
```env
PORT=5172
DATABASE_URL="postgresql://jetkvm:jetkvm@api-db:5432/jetkvm?schema=public"

# Google Auth
GOOGLE_CLIENT_ID=your_id
GOOGLE_CLIENT_SECRET=your_secret

# URLs
API_HOSTNAME=https://your-api-domain.com
APP_HOSTNAME=https://your-app-domain.com

# Storage & Security
COOKIE_SECRET=ChangeThisToSomethingSecureAndLong
CORS_ORIGINS=https://your-app-domain.com

# Reverse Proxy Header
# =X-Real-IP for Nginx
# =CF-Connecting-IP for Cloudflare
# =X-Forwarded-For for Traefik/Haproxy/Nginx
REAL_IP_HEADER=X-Real-IP
```

## Deployment

The provided `deploy.sh` script does the following:

1. Cleans up old builds.
2. Clones the latest stable versions of `jetkvm/kvm` and `jetkvm/cloud-api`.
3. Copies the UI Dockerfile and your `.env` files into place.
4. Spins up the entire stack using Docker Compose.

### To deploy

```sh
git clone https://github.com/Cheblan/jetkvm-selfhost.git
cd jetkvm-selfhost
chmod +x deploy.sh
./deploy.sh
```

## Cloudflare Tunnel / SPA routing (important for adoption)

If you expose the UI through Cloudflare Tunnel (or any reverse proxy that forwards directly to the UI container),
you may hit a 404 when the device redirects to a client-side route like:

`https://<APP_HOSTNAME>/signup?deviceId=...`

This repo’s UI is a Single Page Application (SPA). Routes like `/signup` are handled by the browser app and
must be served with `index.html` (history fallback). If the server returns a real 404 for `/signup`,
the adoption flow breaks.

### Recommended fix: run an SPA-fallback front container (Caddy)

This repo includes an optional compose override that adds a small Caddy front container which:

* passes asset files through unchanged (js/css/png/etc.)
* rewrites all non-asset paths to `/` so the UI returns `index.html`

1. Create the Caddyfile and compose override (already included in this repo):

* `Caddyfile.cloudflare`
* `compose.cloudflare.yaml`

2. Start with both compose files:

```sh
docker compose -f compose.yaml -f compose.cloudflare.yaml up -d --build
```

### Google OAuth redirect URI

When configuring Google OAuth, the redirect URI used by the API is:

`https://<API_HOSTNAME>/oidc/callback`

Add that exact URL in Google Cloud Console → OAuth client → **Authorized redirect URIs**.

### CORS_ORIGINS format

`CORS_ORIGINS` should be a comma-separated list (the API code uses `split(",")`), e.g.:

```dotenv
CORS_ORIGINS=https://app.example.com,https://api.example.com
```

## To be done

1. Add self-hosted coturn TURN server deployment once support is merged in the API: [https://github.com/jetkvm/cloud-api/pull/53](https://github.com/jetkvm/cloud-api/pull/53)
2. Add description on email allowlist once it's merged in main: [https://github.com/jetkvm/cloud-api/commit/8596c72b29403f99418ddb893a332f1d7ce94432](https://github.com/jetkvm/cloud-api/commit/8596c72b29403f99418ddb893a332f1d7ce94432)
