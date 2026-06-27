# G0DM0D3 Research Preview API
# Deploy on Hugging Face Spaces (Docker SDK) or any container host.
#
# Build:  docker build -t g0dm0d3-api .
# Run:    docker run -p 7860:7860 \
#           -e OPENROUTER_API_KEY=sk-or-... \
#           -e GODMODE_API_KEY=your-secret-key \
#           g0dm0d3-api
#
# OPENROUTER_API_KEY: Your OpenRouter key (powers all model calls)
# GODMODE_API_KEY:    Auth key callers must send as Bearer token
# HF_TOKEN:           HuggingFace write token for auto-publishing data
# HF_DATASET_REPO:    Target HF dataset repo (e.g. LYS10S/g0dm0d3-research)

# FROM node:20-slim

# WORKDIR /app

# Copy package files and install deps
# COPY package.json package-lock.json* ./
# RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev

# Copy source (api + engine libs)
# COPY api/ ./api/
# COPY src/lib/ ./src/lib/
# COPY src/stm/ ./src/stm/

# Create non-root user for security
# RUN addgroup --system app && adduser --system --ingroup app app

# HF Spaces expects port 7860
# ENV PORT=7860
# EXPOSE 7860

# Switch to non-root user
# USER app

# Health check for container orchestrators
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
#   CMD curl -f http://localhost:7860/v1/health || exit 1

# CMD ["npx", "tsx", "api/server.ts"]

# G0DM0D3 Research Preview API
FROM node:20-slim

# Install curl so Coolify's health check passes natively
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Create secure non-root user early
RUN addgroup --system app && adduser --system --ingroup app app

# 2. Copy package configurations from the HF folder and install dependencies
COPY HF/package.json HF/package-lock.json* ./
RUN npm ci --omit=dev 2>/dev/null || npm install --omit=dev

# 3. Copy source files from the HF folder and assign ownership to 'app'
COPY --chown=app:app HF/api/ ./api/
COPY --chown=app:app HF/src/lib/ ./src/lib/
COPY --chown=app:app HF/src/stm/ ./src/stm/

# HF Spaces/Coolify binding port
ENV PORT=7860
EXPOSE 7860

# 4. Switch to non-root user context
USER app

# 5. Health check configuration (Will now pass since curl is installed)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:7860/v1/health || exit 1

# 6. Execute the application
CMD ["npx", "tsx", "api/server.ts"]
