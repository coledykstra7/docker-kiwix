-- nginx-processor/lua/body_filter.lua
-- This Lua script is used in Nginx to modify the response body for specific content types

-- Only process if we marked this as HTML in header filter
if not ngx.ctx.process_html then
    return
end

-- Additional safety check - examine the URI again
local uri = ngx.var.request_uri
local has_non_html_extension = ngx.re.find(uri, "\\.(js|css|json|xml|txt|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot|pdf|zip|mp4|webm|ogg)$", "i")

if has_non_html_extension then
    ngx.log(ngx.WARN, "[LUA] Body filter safety check: Skipping non-HTML file: ", uri)
    return
end

local function replace_pattern(content, pattern, replacement, description)
    local count
    content, count = ngx.re.gsub(content, pattern, replacement, "is")
    if count and count > 0 then
        ngx.log(ngx.DEBUG, '[LUA] Replaced ' .. count .. ' occurrences: ' .. (description or pattern))
    end
    return content
end

local chunk = ngx.arg[1]
local eof = ngx.arg[2] -- end of file flag

if chunk then
    -- Initialize buffer if this is the first chunk
    if not ngx.ctx.buffer then
        ngx.ctx.buffer = {}
    end
    
    -- Collect all chunks
    table.insert(ngx.ctx.buffer, chunk)
    
    -- Don't output anything yet
    ngx.arg[1] = nil
end

-- Process the complete response when we reach EOF
if eof then
    ngx.log(ngx.DEBUG, '[LUA] eof: Request - Method: ', ngx.var.request_method, ' URL: ', ngx.var.request_uri, ' Host: ', ngx.var.host)
    local full_content = ""
    if ngx.ctx.buffer then
        full_content = table.concat(ngx.ctx.buffer)
    end
    
    -- Final safety check: examine the content itself
    local looks_like_html = full_content:match("<!DOCTYPE") or 
                           full_content:match("<html") or 
                           full_content:match("<HTML") or
                           full_content:match("<head") or
                           full_content:match("<body")
    
    if not looks_like_html then
        ngx.log(ngx.WARN, "[LUA] Body filter content check: Content doesn't look like HTML, skipping processing for: ", uri)
        ngx.arg[1] = full_content
        return
    end
    
    if ngx.re.find(ngx.var.request_uri, "milneopentextbooks", "i") then
        ngx.log(ngx.DEBUG, '[LUA] body_filter milneopentextbooks Method: ', ngx.var.request_method, ' URL: ', ngx.var.request_uri, ' Host: ', ngx.var.host)
        -- Define a pattern for links with href containing /download/ and text containing "download ebook".
        local download_pattern = '<a[^>]*?href=[^>]*?/download/[^>]*?>[^<]*?download ebook[^<]*?</a>'
        full_content = replace_pattern(full_content, download_pattern, "", "Specific 'download ebook' links on Milne page")

        -- Pattern to match <a> tags with /download/ in href and "download pdf" in inner text
        local pattern = [[<a([^>]*?href=["'][^"']*/download/[^"']*?["'][^>]*)>([^<]*?)download pdf([^<]*?)</a>]]
        -- Replacement string: replaces just "download pdf" with "View PDF", preserving before/after text
        local replacement = '<a$1>$2View PDF$3</a>'
        full_content = replace_pattern(full_content, pattern, replacement, "Changed 'download pdf' to 'View PDF' on Milne page")
    end

    -- Strip external links - multiple patterns for better coverage
    local external_link_patterns = {
        -- Basic HTTP/HTTPS links
        '<a[^>]*?href=["\']https?://[^"\']*?["\'][^>]*?>(.*?)</a>',
        
        -- Links with additional protocols (ftp, mailto, etc.)
        '<a[^>]*?href=["\'](?:ftp|mailto|tel)://[^"\']*?["\'][^>]*?>(.*?)</a>',
        
        -- Links that might have spaces or other attributes
        '<a\\s+[^>]*?href\\s*=\\s*["\']https?://[^"\']*?["\'][^>]*?>(.*?)</a>',
        
        -- Handle single quotes vs double quotes
        "<a[^>]*?href='https?://[^']*?'[^>]*?>(.*?)</a>",
        
        -- Catch any remaining external links (starting with http/https)
        '<a[^>]*?href=[^>]*?(?:https?://)[^>]*?>(.*?)</a>'
    }
    
    -- Apply each pattern
    for i, pattern in ipairs(external_link_patterns) do
        full_content = replace_pattern(full_content, pattern, "$1", "External links (pattern " .. i .. ")")
    end

    -- Output the modified content
    ngx.arg[1] = full_content
    
    ngx.log(ngx.DEBUG, "[LUA] Body filter processed HTML content, size: ", string.len(full_content))
end