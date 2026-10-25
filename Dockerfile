# Production Dockerfile for Minds Telemedicine Platform
FROM node:20-bookworm-slim

# Install system native libraries required by canvas, sharp, and poppler
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    poppler-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Install all npm dependencies (including devDependencies required for Next.js build)
COPY package*.json ./
RUN npm install --legacy-peer-deps --include=dev

# Copy application source code
COPY . .

# Provide build-time fallback dummy environment variables so Next.js static compilation never fails
ENV GEMINI_API_KEY="AIzaSyDummyBuildKeyForDockerBuild12345"
ENV MONGODB_URI="mongodb://127.0.0.1:27017/build_dummy"
ENV MONGODB_ATLAS_URI="mongodb://127.0.0.1:27017/build_dummy"
ARG NEXTAUTH_SECRET="build-secret-key-32-chars-minimum-required"
ARG NEXTAUTH_URL="http://localhost:3000"
ENV NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
ENV NEXTAUTH_URL=${NEXTAUTH_URL}

# Build Next.js application
RUN npm run build

# Switch to production environment for container runtime
ENV NODE_ENV=production

# Expose application port
EXPOSE 3000

# Health check to ensure the custom server is up
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3000}/api/health || exit 1

# Start the custom server with Socket.io enabled
CMD ["node", "server.js"]
