# Stage 1: Building the Next.js application
FROM node:18-alpine as builder
WORKDIR /app

# Install dependencies
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else echo "No lockfile found." && exit 1; \
  fi

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# If you're generating a fully static site (optional step)
# RUN npm run export

# Stage 2: Serving the application with Nginx
FROM nginx:stable-alpine as production-stage

# Copy the built app to the Nginx serve directory
COPY --from=builder /app/out /usr/share/nginx/html

# For non-static sites, you might need to configure Nginx to forward requests to a Node.js server
# For static sites, this setup can serve the exported static files directly

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
