# Docker Kiwix

A containerized setup for running Kiwix server with a two-layer nginx proxy: one for content processing and filtering, and one for caching and external access.

## Features

- **Kiwix Server**: Serves ZIM files (offline Wikipedia, educational content, etc.)
- **nginx-processor (OpenResty)**: Advanced reverse proxy with Lua scripting for content filtering, link stripping, and custom error handling
- **nginx-cache**: Caching, compression, and security headers for external access
- **Custom Error Pages**: Branded error handling for blocked content and searches
- **Development-Friendly**: Externally mounted configurations for easy testing
- **Optional Basic Authentication**: Easily secure your instance with a username and password.

## Architecture

```
Internet → nginx-cache:8888 → nginx-processor:8080 → kiwix:8000 → ZIM files
```

- **nginx-cache: Acts as the public gateway.**: Handles caching, compression, and security headers. Forwards requests to `nginx-processor`.
- **nginx-processor: Filters and processes content.** (OpenResty): Uses Nginx/Lua to strip external links and apply custom rules before forwarding requests to `kiwix`. No awareness of `nginx-cache`.
- **kiwix: Serves the ZIM content.**: Responds to requests from `nginx-processor` without any awareness of the upstream proxies.
- **Volumes**: Configuration and content files mounted externally for easy development.

## Prerequisites

- Docker and Docker Compose
- ZIM files (download from [Kiwix](https://www.kiwix.org/en/downloads/))

## Quick Start

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/coledykstra7/docker-kiwix.git
    cd docker-kiwix
    ```

2.  **Create Content Directory and Add ZIM Files 📚**
    Create the `zims` directory, then place your Kiwix ZIM files (`.zim`) inside it. The Kiwix container will automatically detect and serve any files it finds here.
    ```bash
    mkdir zims
    # Now, move/copy your .zim files into the new ./zims folder
    ```

3.  **Start the Services**
    ```bash
    docker-compose up -d
    ```

4.  **Access Kiwix**
    - Open your browser to `http://localhost:8888`
    - Browse your offline content!

## Security: Enabling Password Protection (Optional)

You can easily protect your Kiwix instance with a username and password (Basic Authentication). The `nginx-cache` service is pre-configured to enable authentication automatically if a password file is found.

1.  **Create the Secrets Directory**
    This directory will hold your password file.
    ```bash
    mkdir -p ./nginx-cache/secrets
    ```

2.  **Create the Password File (`.htpasswd`)**
    Run the following command to create a `.htpasswd` file. It uses a temporary `xmartlabs/htpasswd` container to generate the password hash, so you don't need to install any extra tools on your host machine.

    Replace `USERNAME` with the username you want.
    Replace `PASSWORD` with the password you want.

    ```bash
    docker run --rm -ti xmartlabs/htpasswd USERNAME PASSWORD > ./nginx-cache/secrets/.htpasswd
    ```

    *To add more users, run the command again with a different username and append `>>` instead of `>`.*

3.  **Restart the Services**
    Apply the changes by restarting your containers.
    ```bash
    docker-compose restart
    ```

Now, when you access `http://localhost:8888`, your browser will prompt you for the username and password you just created. To disable authentication, simply delete the `./nginx-cache/secrets/.htpasswd` file and restart the services.

## Configuration

### nginx-processor Configuration

The nginx-processor configuration (`nginx-processor/nginx.conf`) includes:

- **Content Blocking**: Configurable patterns to block specific content
- **Link Stripping**: Removes external HTTP/HTTPS links from pages
- **Content Modification**: Text replacement and processing via Lua
- **Custom Error Pages**: Located in `nginx-processor/html/`

### nginx-cache Configuration

The nginx-cache configuration (`nginx-cache/conf.d/default.conf`) includes:

- **Caching**: Improves performance for repeated requests
- **Compression**: Reduces bandwidth usage
- **Security Headers**: Adds basic security headers
- **Authentication**: Automatically enabled if `/etc/nginx/secrets/.htpasswd` exists.

### Content Filtering

Current filtering rules (configurable in `nginx-processor/nginx.conf`):

```lua
-- Block specific content patterns
if ngx.re.find(uri, "/content/gutenberg.*Kama.*Sutra", "i") or
   ngx.re.find(uri, "/content.*wikipedia.*/lion", "i") or
   ngx.re.find(uri, "/content.*wikipedia.*/tiger", "i") or
   ngx.re.find(uri, "/content.*wikipedia.*/bear", "i")
then
    is_blocked = true
end
```

### Custom Pages

- `nginx-processor/html/catch_block.html` - Shown for blocked content
- `nginx-processor/html/catch_external.html` - Handles external link requests
- `nginx-processor/html/catch_search.html` - Custom search page
- `nginx-processor/html/index.html` - Landing page

## Development

### Modifying Configuration

Since configurations are mounted externally, you can edit them without rebuilding containers:

```bash
# Edit nginx-processor configuration
nano nginx-processor/nginx.conf

# Edit nginx-cache configuration
nano nginx-cache/conf.d/default.conf

# Reload nginx-processor without rebuilding
docker exec kiwix-nginx-processor nginx -s reload

# Reload nginx-cache without rebuilding
docker exec kiwix-nginx-cache nginx -s reload
```

### Viewing Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs nginx-processor
docker-compose logs nginx-cache
docker-compose logs kiwix

# Follow logs in real-time
docker-compose logs -f
```

### Debugging

The nginx-processor configuration includes debug logging. Check the logs for detailed processing information:

```bash
docker-compose logs nginx-processor | grep -i debug
```

## File Structure

```
docker-kiwix/
├── docker-compose.yml                # Container orchestration
├── .gitignore                        # Git ignore rules
├── kiwix/
│   └── Dockerfile                    # Kiwix container build
│   └── entrypoint.sh                 # Entrypoint script for kiwix
├── nginx-processor/
│   ├── Dockerfile                    # Nginx processor container build
│   ├── nginx.conf                    # Main nginx configuration
│   └── html/                         # Custom HTML pages
│       ├── catch_block.html
│       ├── catch_external.html
│       ├── catch_search.html
│       └── index.html
├── nginx-cache/
│   ├── Dockerfile                    # Nginx cache container build
│   ├── conf.d/
│   │   └── default.conf              # Cache nginx configuration
│   └── secrets/                      # (Optional) Holds .htpasswd file
```

## Ports

- **8888**: External access port (nginx-cache)
- **8080**: Internal processor port (nginx-processor, not exposed externally)
- **8000**: Internal Kiwix server port (kiwix, not exposed externally)

## Volumes

* `./zims:/zims`: Maps the local `./zims` directory, containing your ZIM files, into the `kiwix` container.
* `./nginx-processor/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro`: Mounts your custom configuration file over the default `nginx.conf` for the `nginx-processor` service.
* `./nginx-processor/html:/usr/local/openresty/nginx/html:ro`: Provides custom HTML pages (like block/catch pages) to the `nginx-processor`.
* `./nginx-cache/conf.d:/etc/nginx/conf.d:ro`: Provides the configuration for the `nginx-cache` service.
* `./nginx-cache/secrets:/etc/nginx/secrets:ro`: (Optional) Provides the `.htpasswd` file for Basic Authentication. The directory is mounted read-only for security.
* `cache-data:/var/cache/nginx`: A named volume managed by Docker to persistently store NGINX cache data.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test with `docker compose up -d`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Kiwix](https://www.kiwix.org/) - Offline content serving
- [OpenResty](https://openresty.org/) - High-performance web platform
- [Nginx](https://nginx.org/) - Web server and reverse proxy
- [Docker](https://www.docker.com/) - Containerization platform

## Support

If you encounter issues:

1.  **Check the logs for a specific service.** This is the most important step.
    -   `docker compose logs kiwix-nginx-cache`
    -   `docker compose logs kiwix-nginx-processor`
    -   `docker compose logs kiwix`

2.  **Verify your ZIM files** are placed directly inside the local `./zims` directory.

3.  **Ensure the `entrypoint.sh` script** inside the `./kiwix` directory is creating the library file correctly. Check the `kiwix` service logs for its status messages.

4.  **Open an issue on GitHub** with the relevant log output from the failing service.