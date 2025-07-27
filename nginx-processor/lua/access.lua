-- nginx-processor/lua/access.lua
-- This Lua script is used in Nginx to block specific requests based on URI patterns.

local ip = ngx.var.remote_addr
local uri = ngx.var.request_uri

local is_blocked = false

-- Global Rules (for ALL IPs)
-- Using ngx.re.find for PCRE regex matching as it's more flexible
-- and closer to Nginx's native regex. 'i' for case-insensitive.
if ngx.re.find(uri, "/content/gutenberg.*Kama.*Sutra", "i") or
ngx.re.find(uri, "/content.*wikipedia.*/lion", "i") or
ngx.re.find(uri, "/content.*wikipedia.*/tiger", "i") or
ngx.re.find(uri, "/content.*wikipedia.*/bear", "i")
then
    is_blocked = true
end

if is_blocked then
    ngx.log(ngx.WARN, "[LUA] Blocked request from IP: ", ip, " for URI: ", uri)
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end