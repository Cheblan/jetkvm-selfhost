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
5. **Authorized JavaScript origins**: Add `https://your-ui-domain.com` and `https://your-api-domain.com`
6. **Authorized redirect URIs**: Add `https://your-api-domain.com/oidc/callback`, `https://your-api-domain.com/oidc/callback_o`, `https://your-api-domain.com/oidc/google`.
7. Copy your `Client ID` and `Client Secret`.

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
APP_HOSTNAME=https://your-ui-domain.com

# Storage & Security
COOKIE_SECRET=ChangeThisToSomethingSecureAndLong
CORS_ORIGINS=https://your-ui-domain.com

# Reverse Proxy Header
# =X-Real-IP for Nginx
# =CF-Connecting-IP for Cloudflare
# =X-Forwarded-For for Traefik/Haproxy/Nginx
REAL_IP_HEADER=X-Real-IP

# Allowed account emails, split by comma (leave empty to allow all)
ALLOWED_IDENTITIES=
```

## Deployment

The provided deploy.sh script does the following:
1. Cleans up old builds.
2. Clones the latest stable versions of jetkvm/kvm and jetkvm/cloud-api.
3. Copies UI Dockerfile and your .env files to cloned local repos.
4. Spins up the entire stack using Docker Compose.

### To deploy:
```sh
git clone https://github.com/Cheblan/jetkvm-selfhost.git
cd jetkvm-selfhost
chmod +x deploy.sh
./deploy.sh
```

## To be done

1. Add self-hosted coturn TURN server deployment once support is merged in the API: [https://github.com/jetkvm/cloud-api/pull/53](https://github.com/jetkvm/cloud-api/pull/53)
