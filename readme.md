# Docker Kiwix

A containerized setup for running Kiwix server with a two-layer nginx proxy: one for content processing and filtering, and one for caching and external access.

## Features

- **Kiwix Server**: Serves ZIM files (offline Wikipedia, educational content, etc.)
- **nginx-processor (OpenResty)**: Advanced reverse proxy with Lua scripting for content filtering, link stripping, and custom error handling
- **nginx-cache**: Caching, compression, and security headers for external access
- **Custom Error Pages**: Branded error handling for blocked content and searches
- **Development-Friendly**: Externally mounted configurations for easy testing

## Architecture

```
Internet → nginx-cache:8888 → nginx-processor:8080 → kiwix:8000 → ZIM files (in kiwix-data volume)
```

- **nginx-cache**: Handles caching, compression, and security headers. Forwards requests to nginx-processor.
- **nginx-processor** (OpenResty): Performs content filtering, link stripping, and custom error handling via Lua.
- **kiwix**: Serves ZIM files and handles search functionality.
- **Volumes**: Configuration and content files mounted externally for easy development.

## Prerequisites

- Docker and Docker Compose
- ZIM files (download from [Kiwix](https://www.kiwix.org/en/downloads/))

## Quick Start

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/coledykstra7/docker-kiwix.git](https://github.com/coledykstra7/docker-kiwix.git)
    cd docker-kiwix
    ```

2.  **Add Your Content 📚**
    Place your Kiwix ZIM files (`.zim`) into the `./zims` directory. The Kiwix container will automatically detect and serve any files it finds here.

3.  **Start the Services**
    ```bash
    docker-compose up -d
    ```

4.  **Access Kiwix**
    - Open your browser to `http://localhost:8888`
    - Browse your offline content!

## Configuration

### nginx-processor Configuration

The nginx-processor configuration (`nginx-processor/conf.d/nginx.conf`) includes:

- **Content Blocking**: Configurable patterns to block specific content
- **Link Stripping**: Removes external HTTP/HTTPS links from pages
- **Content Modification**: Text replacement and processing via Lua
- **Custom Error Pages**: Located in `nginx-processor/html/`

### nginx-cache Configuration

The nginx-cache configuration (`nginx-cache/conf.d/default.conf`) includes:

- **Caching**: Improves performance for repeated requests
- **Compression**: Reduces bandwidth usage
- **Security Headers**: Adds basic security headers

### Content Filtering

Current filtering rules (configurable in `nginx-processor/conf.d/nginx.conf`):

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
vim nginx-processor/conf.d/nginx.conf

# Edit nginx-cache configuration
vim nginx-cache/conf.d/default.conf

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
│   └── conf.d/
│       └── default.conf              # Cache nginx configuration
```

## Ports

- **8888**: External access port (nginx-cache)
- **8080**: Internal processor port (nginx-processor, not exposed externally)
- **8000**: Internal Kiwix server port (kiwix, not exposed externally)

## Volumes

- `kiwix-data:/data`: ZIM files and library configuration (managed by Docker)
- `cache-data:/var/cache/nginx`: Nginx cache data (managed by Docker)
- `./nginx-processor/html:/usr/local/openresty/nginx/html:ro`: Custom HTML pages
- `./nginx-processor/conf.d:/usr/local/openresty/nginx/conf.d:ro`: Nginx processor configuration
- `./nginx-cache/conf.d:/etc/nginx/conf.d:ro`: Nginx cache configuration

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test with `docker-compose up -d`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Kiwix](https://www.kiwix.org/) - Offline content serving
- [OpenResty](https://openresty.org/) - High-performance web platform
- [Docker](https://www.docker.com/) - Containerization platform

## Support

If you encounter issues:

1. Check the logs: `docker-compose logs`
2. Verify your ZIM files are in the `kiwix-data` volume
3. Ensure `mylib.xml` is properly configured
4. Open an issue on GitHub with relevant log output