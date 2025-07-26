# nginx-cache Dockerfile
FROM nginx:alpine

# Install nginx-module-cache-purge if needed
# RUN apk add --no-cache nginx-mod-http-cache-purge

# Create cache directory
RUN mkdir -p /var/cache/nginx/kiwix && \
    chown -R nginx:nginx /var/cache/nginx

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# The actual config will be mounted from host

# Copy our custom startup script into the Nginx entrypoint directory.
# Scripts in this directory are executed by the main entrypoint script before Nginx starts.
COPY ./40-conditional-auth.sh /docker-entrypoint.d/40-conditional-auth.sh

# Make the script executable
RUN chmod +x /docker-entrypoint.d/40-conditional-auth.sh

