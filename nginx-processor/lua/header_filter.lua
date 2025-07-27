-- nginx-processor/lua/header_filter.lua
-- More robust content type detection with debugging

local content_type = ngx.header["Content-Type"]
local uri = ngx.var.request_uri

-- Store content type in context for body filter to use
ngx.ctx.content_type = content_type

-- More comprehensive checks to determine if this is HTML content
local is_html = false
local should_process = false
local has_non_html_extension = false
local is_api_or_static = false

-- Check 1: Content-Type header
if content_type and content_type:match("text/html") then
    is_html = true
    -- Check 2: File extension in URI (override content-type if needed)
    if ngx.re.find(uri, "\\.(js|css|json|xml|txt|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot|pdf|zip|mp4|webm|ogg)$", "i") then
        has_non_html_extension = true
    end

    -- Check 3: Special paths that should never be processed
    if ngx.re.find(uri, "(/api/|/_zim_static/|/gtag/|www\\.googletagmanager\\.com)", "i") then
        is_api_or_static = true
    end
end

-- Decision logic
if is_html and not has_non_html_extension and not is_api_or_static then
    should_process = true
end

-- Debug logging to see what's happening
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - URI: ", uri)
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - Content-Type: ", tostring(content_type))
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - is_html: ", tostring(is_html))
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - has_non_html_extension: ", tostring(has_non_html_extension))
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - is_api_or_static: ", tostring(is_api_or_static))
-- ngx.log(ngx.DEBUG, "[LUA] Header filter - should_process: ", tostring(should_process))

if should_process then
    -- Clear Content-Length because body size will change after modification
    ngx.header["Content-Length"] = nil
    ngx.header["X-Lua-Processed"] = "true"
    ngx.ctx.process_html = true
    ngx.log(ngx.DEBUG, "[LUA] Header filter PROCESSING: ", uri)
else
    -- Don't process non-HTML content or static resources
    ngx.ctx.process_html = false
    ngx.log(ngx.DEBUG, "[LUA] Header filter SKIPPING: ", uri)
end