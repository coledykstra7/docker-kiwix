FROM nginx:alpine

# Install nginx-module-cache-purge if needed
# RUN apk add --no-cache nginx-mod-http-cache-purge

# Create cache directory
RUN mkdir -p /var/cache/nginx/kiwix && \
    chown -R nginx:nginx /var/cache/nginx

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# The actual config will be mounted from host
