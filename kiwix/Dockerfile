FROM alpine:latest

RUN apk add --no-cache curl tar libstdc++ \
 && curl -L -o /tmp/kiwix-tools.tar.gz https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz \
 && mkdir -p /usr/local/kiwix \
 && tar -xzf /tmp/kiwix-tools.tar.gz -C /usr/local/kiwix --strip-components=1 \
 && rm /tmp/kiwix-tools.tar.gz

# Add the kiwix directory to the system's PATH
ENV PATH="/usr/local/kiwix:${PATH}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /data
EXPOSE 8000
ENTRYPOINT ["/entrypoint.sh"]
