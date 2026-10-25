# 🚀 Deployment Guide for Minds Telemedicine Platform

This application uses **Next.js 14** along with a custom Node.js HTTP server running **Socket.io** (`server.js`) for real-time video calls and notifications, as well as native libraries (`canvas`, `sharp`, `poppler-utils`).

Because persistent WebSockets and native Linux binary libraries are required, containerized **Docker deployment** is the most reliable method across all platforms.

---

## 📋 Required Environment Variables

Before deploying, ensure you have values for these environment variables (can be set in the platform's dashboard or in a `.env.local` / `.env` file):

| Variable | Description |
| :--- | :--- |
| `NODE_ENV` | `production` |
| `PORT` | `3000` (or assigned automatically by the platform) |
| `NEXTAUTH_URL` | Your public production URL (e.g., `https://your-app.up.railway.app`) |
| `NEXTAUTH_SECRET` | Strong random secret (generate via `openssl rand -base64 32`) |
| `MONGODB_URI` / `MONGODB_ATLAS_URI` | Your MongoDB connection string |
| `GEMINI_API_KEY` | Google Gemini API key |
| `GOOGLE_CLIENT_ID` | *(Optional)* Google OAuth Client ID |
| `GOOGLE_CLIENT_SECRET` | *(Optional)* Google OAuth Client Secret |
| `NEXT_PUBLIC_VAPI_PUBLIC_KEY` | *(Optional)* Vapi AI public key |
| `NEXT_PUBLIC_VAPI_ASSISTANT_ID` | *(Optional)* Vapi AI assistant ID |
| `TWILIO_SID` | *(Optional)* Twilio Account SID |
| `TWILIO_AUTH` | *(Optional)* Twilio Auth Token |
| `TWILIO_WHATSAPP_NUMBER` | *(Optional)* Twilio WhatsApp number |
| `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`| *(Optional)* Google Maps API key |

> **MongoDB Whitelist Note:** Ensure that your MongoDB Atlas Network Access whitelist includes `0.0.0.0/0` (Allow Access from Anywhere) so your cloud container can reach the database.

---

## Option 1: Railway (Recommended — Fastest & Easiest)

Railway natively detects the `Dockerfile` and supports continuous WebSockets without dropping connections.

1. Go to [railway.com](https://railway.com) and log in.
2. Click **New Project** → **Deploy from GitHub repo**.
3. Select this repository (`nothing123-a/WT`).
4. Railway will automatically detect the [Dockerfile](file:///d:/telemedicine/Telemedicines/Dockerfile).
5. Go to the **Variables** tab and add the environment variables listed above.
6. Under **Settings** → **Networking**, click **Generate Domain** to get your public HTTPS URL.
7. Set `NEXTAUTH_URL` to this generated domain.

---

## Option 2: Render (Using Docker)

Render supports Docker web services with custom ports and WebSockets.

1. Go to [render.com](https://render.com) and log in.
2. Click **New** → **Web Service** → Connect your GitHub repository.
3. Configuration:
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./Dockerfile`
   - **Region**: Choose closest to your users
4. In the **Environment Variables** section, paste the values from your `.env.local`.
5. Click **Create Web Service**.

*(Alternatively, use Render's Blueprint feature which automatically reads [render.yaml](file:///d:/telemedicine/Telemedicines/render.yaml)).*

---

## Option 3: Fly.io

Fly.io runs the Docker container on lightweight Firecracker microVMs close to users:

1. Install Fly CLI:
   - Windows (PowerShell): `pwsh -Command "iwr https://fly.io/install.ps1 -useb | iex"`
   - Mac/Linux: `curl -L https://fly.io/install.sh | sh`
2. Log in:
   ```bash
   fly auth login
   ```
3. Initialize the app:
   ```bash
   fly launch
   ```
   (Fly will detect the `Dockerfile` and generate `fly.toml` on port `3000`).
4. Set secrets:
   ```bash
   fly secrets set NEXTAUTH_SECRET="your-secret" MONGODB_URI="your-uri" GEMINI_API_KEY="your-key" NEXTAUTH_URL="https://your-app.fly.dev"
   ```
5. Deploy:
   ```bash
   fly deploy
   ```

---

## Option 4: VPS / Cloud Server (Ubuntu/Debian, AWS EC2, DigitalOcean)

If deploying to your own server using [docker-compose.yml](file:///d:/telemedicine/Telemedicines/docker-compose.yml):

1. SSH into your VPS:
   ```bash
   ssh user@your-server-ip
   ```
2. Clone repository & enter directory:
   ```bash
   git clone https://github.com/nothing123-a/WT.git
   cd WT
   ```
3. Create your production environment file:
   ```bash
   cp .env.example .env.local
   nano .env.local   # fill in your real production credentials
   ```
4. Build and start the container:
   ```bash
   docker compose up --build -d
   ```
5. Check status and logs:
   ```bash
   docker compose logs -f
   ```
   The application is now running on port `3000` (can be put behind NGINX or Caddy for automatic SSL).
