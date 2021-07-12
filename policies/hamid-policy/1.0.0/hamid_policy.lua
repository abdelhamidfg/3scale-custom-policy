local _M = require('apicast.policy').new('Hamid Policy', '1.0.0')
local mymathmodule = require("mymath")
local new = _M.new
local http_ng = require('resty.http_ng')
local ipairs = ipairs
local insert = table.insert

function _M.new(configuration)
  local self = new()
   mymathmodule.add(10,20)
  local ops = {}
 local httpc = require("resty.http").new()
 local res, err = httpc:request_uri("http://example.com/helloworld", {
    method = "GET",
    body = "a=1&b=2",
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
    },
})
if not res then
    ngx.log(ngx.ERR, "request failed: ", err)
    return
end

-- At this point, the entire request / response is complete and the connection
-- will be closed or back on the connection pool.

-- The `res` table contains the expeected `status`, `headers` and `body` fields.
local status = res.status
local length = res.headers["Content-Length"]
local body   = res.body 
  local config = configuration or {}
  local set_header = config.set_header or {}
  local x= mymathmodule.add(10,20)
  for _, header in ipairs(set_header) do
    insert(ops, function()
      ngx.log(ngx.ERR, 'setting header V1: ', x, ' to: ', header.value)
      ngx.req.set_header(x, header.value)
    end)
  end

  self.ops = ops

  return self
end

function _M:rewrite()
ngx.log(ngx.ERR,'rewrite start')
  for _,op in ipairs(self.ops) do
    op()
  end
end

return _M
