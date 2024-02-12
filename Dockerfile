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

# Stage 2: Serving the application with Nginx
FROM nginx:stable-alpine as production-stage

# Copy the built app to the Nginx serve directory
# Adjust this line if you're not exporting to static HTML
COPY --from=builder /app/.next/static /usr/share/nginx/html/_next/static
COPY --from=builder /app/public /usr/share/nginx/html

# Copy a custom Nginx config if you have one
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
