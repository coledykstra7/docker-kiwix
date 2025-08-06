# nginx-cache Dockerfile
FROM nginx:alpine

# Install nginx-module-cache-purge if needed
# RUN apk add --no-cache nginx-mod-http-cache-purge

# Create cache directory structure with initial symlink (only if needed)
RUN mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    if [ ! -L /var/cache/nginx/kiwix ]; then \
        INITIAL_CACHE_DIR="kiwix_cache_$(date +%s)" && \
        mkdir -p "/var/cache/nginx/$INITIAL_CACHE_DIR" && \
        ln -sf "$INITIAL_CACHE_DIR" /var/cache/nginx/kiwix && \
        echo "Created initial cache symlink: /var/cache/nginx/kiwix -> $INITIAL_CACHE_DIR"; \
    else \
        echo "Cache symlink already exists, preserving existing setup"; \
    fi

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# The actual config will be mounted from host

# Copy our custom startup script into the Nginx entrypoint directory.
# Scripts in this directory are executed by the main entrypoint script before Nginx starts.
COPY ./40-conditional-auth.sh /docker-entrypoint.d/40-conditional-auth.sh

# Make the script executable
RUN chmod +x /docker-entrypoint.d/40-conditional-auth.sh

