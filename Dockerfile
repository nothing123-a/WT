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

# Set build-time environments
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Install npm dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy application source
COPY . .

# Build-time dummy variables to satisfy static compilation
ARG NEXTAUTH_SECRET="build-secret-key-32-chars-minimum-required"
ARG NEXTAUTH_URL="http://localhost:3000"
ENV NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
ENV NEXTAUTH_URL=${NEXTAUTH_URL}

# Build Next.js application
RUN npm run build

# Expose application port
EXPOSE 3000

# Health check to ensure the custom server is up
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start the custom server with Socket.io enabled
CMD ["node", "server.js"]
