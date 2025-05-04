-- Lua script to block sensitive JSON-RPC methods
-- Works with nginx.ingress.kubernetes.io/lua-snippet or OpenResty

local cjson = require "cjson"
local blocked_methods = {
  ["admin_*"] = true,
  ["debug_*"] = true,
  ["miner_*"] = true,
  ["personal_*"] = true,
  ["txpool_*"] = true,
  ["eth_sendTransaction"] = true
}

-- Read request body
ngx.req.read_body()
local data = ngx.req.get_body_data()

if data then
  local ok, req = pcall(cjson.decode, data)
  if ok and req.method then
    for pattern, _ in pairs(blocked_methods) do
      local m = pattern:gsub("%*", ".*")
      if req.method:match("^" .. m .. "$") then
        ngx.status = ngx.HTTP_FORBIDDEN
        ngx.say("{\"error\": \"method not allowed\"}")
        return ngx.exit(ngx.HTTP_FORBIDDEN)
      end
    end
  end
end

-- Allow if not blocked
return
# README.md (additions)
### JSON-RPC Method Filtering (Lua)
A Lua-based middleware script is included to block sensitive Ethereum JSON-RPC methods:
- `admin_*`
- `debug_*`
- `miner_*`
- `personal_*`
- `txpool_*`
- `eth_sendTransaction`